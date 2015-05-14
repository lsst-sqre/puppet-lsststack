# == Define: lsststack::lsstsw
#
define lsststack::lsstsw(
  $user            = $title,
  $group           = $title,
  $manage_user     = true,
  $manage_group    = true,
  $lsstsw_repo     = 'https://github.com/lsst/lsstsw.git',
  $lsstsw_branch   = 'master',
  $buildbot_repo   = 'https://github.com/lsst-sqre/buildbot-scripts.git',
  $buildbot_branch = 'master',
  $debug           = false,
) {
  include ::wget

  # only needed for dependencies when lsst_build attempts to build eups
  # packages
  Class[lsststack] -> Lsststack::Lsstsw[$title]

  validate_string($user)
  validate_string($group)
  validate_bool($manage_user)
  validate_bool($manage_group)
  validate_string($lsstsw_repo)
  validate_string($lsstsw_branch)
  validate_string($buildbot_repo)
  validate_string($buildbot_branch)
  validate_bool($debug)

  if $manage_user {
    user { $user:
      ensure     => present,
      gid        => $group,
      managehome => true,
      shell      => '/bin/bash',
    }
  }

  if $manage_group {
    group { $group:
      ensure => present,
    }
  }

  # If the user resource is declared externally, and it has the home parameter
  # set, extract it.
  if $debug {
    unless defined(User[$user]) {
      fail("resource User[${user}] is required")
    }
  }
  $user_home = getparam(User[$user], 'home')
  # As the user resource is a native type, we can't introspec on undeclared
  # params from the manifest.  If the home param is undeclared assume that
  # `HOME=/home/$USER`.
  $home = $user_home ? {
    ''      => "/home/${user}", # puppet 4.0
    undef   => "/home/${user}", # puppet 3.7
    default => $user_home,
  }

  $lsstsw = "${home}/lsstsw"
  $buildbot = "${home}/buildbot-scripts"

  # afwdata git bundle download hack
  $afwdata_s3     = 'http://lsst-repos.s3.amazonaws.com/afwdata.bundle'
  $afwdata_bundle = "${home}/afwdata.bundle"
  $afwdata_clone  = "${lsstsw}/build/afwdata"
  $afwdata_repo   = 'git://git.lsstcorp.org/LSST/DMS/testdata/afwdata.git'

  vcsrepo { $lsstsw:
    ensure   => present,
    provider => git,
    user     => $user,
    group    => $group,
    source   => $lsstsw_repo,
    revision => $lsstsw_branch,
  }

  vcsrepo { $buildbot:
    ensure   => present,
    provider => git,
    user     => $user,
    group    => $group,
    source   => $buildbot_repo,
    revision => $buildbot_branch,
  }

  wget::fetch { $afwdata_bundle:
    source      => $afwdata_s3,
    destination => $afwdata_bundle,
    execuser    => $user,
    timeout     => 3600,
    verbose     => false,
  }

  if $debug {
    # Cache a copy of the bundle file as a convience for when manually testing
    # by blowing away the lsstsw user without having to wait for the 3+ GB
    # bundle to be redownloaded.
    #
    # E.g., `userdel -r $user`
    Wget::Fetch[$afwdata_bundle] {
      cache_dir => '/tmp',
    }
  }

  # `lsst_build prepare` commits the build manifest to versiondb and git will
  # exit with a status of 128 if an author is not set.
  #
  # note that .gitconfig indents with tabs
  $gitconfig = '[user]
	name = LSST Data Management
	email = dm-devel@lists.lsst.org
'

  file { '.gitconfig':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0664',
    path    => "${home}/.gitconfig",
    content => $gitconfig,
  }

  $deploy_deps = [
    Vcsrepo[$lsstsw],
    Vcsrepo[$buildbot],
    File['.gitconfig'],
  ]

  exec { 'deploy':
    command     => "${lsstsw}/bin/deploy",
    path        => ['/bin', '/usr/bin'],
    environment => ["LSSTSW=${lsstsw}"],
    creates     => "${lsstsw}/lfs/bin/numdiff",
    user        => $user,
    timeout     => 3600,
    require     => $deploy_deps,
  } ->
  exec { 'afwdata_clone':
    command => "git clone -b master ${afwdata_bundle} ${afwdata_clone}",
    path    => ["${lsstsw}/lfs/bin", '/bin', '/usr/bin'],
    cwd     => $home,
    creates => $afwdata_clone,
    user    => $user,
    timeout => 3600,
    require => Wget::Fetch[$afwdata_bundle],
  } ->
  exec { 'git remote rm origin': } ->
  exec { 'git remote add origin':
    command => "git remote add origin ${afwdata_repo}",
  } ->
  exec { 'git pull origin master': } ->
  exec { 'git branch --set-upstream-to=origin/master': } ->
  exec { 'rebuild -p':
    command     => "source ${lsstsw}/bin/setup.sh && ${lsstsw}/bin/rebuild -p",
    path        => ['/bin', '/usr/bin'],
    environment => ["LSSTSW=${lsstsw}"],
    cwd         => $lsstsw, # XXX is this required?
    refreshonly => true,
    logoutput   => true,
    user        => $user,
    timeout     => 7200,
    provider    => shell,
    subscribe   => Exec['deploy'],
  }

  Exec[
    'git remote rm origin',
    'git remote add origin',
    'git pull origin master',
    'git branch --set-upstream-to=origin/master'
  ] {
    path        => ["${lsstsw}/lfs/bin", '/bin', '/usr/bin'],
    cwd         => $afwdata_clone,
    refreshonly => true,
    user        => $user,
    timeout     => 3600,
    subscribe   => Exec['afwdata_clone'],
  }
}
