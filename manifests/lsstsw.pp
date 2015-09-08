# == Define: lsststack::lsstsw
#
define lsststack::lsstsw(
  $user              = $title,
  $group             = $title,
  $manage_user       = true,
  $manage_group      = true,
  $lsstsw_repo       = hiera('lsststack::lsstsw::lsstsw_repo',
                              'https://github.com/lsst/lsstsw.git'),
  $lsstsw_branch     = hiera('lsststack::lsstsw::lsstsw_branch',
                              'master'),
  $lsstsw_ensure     = hiera('lsststack::lsstsw::lsstsw_ensure',
                              'present'),
  $buildbot_repo     = hiera('lsststack::lsstsw::buildbot_repo',
                          'https://github.com/lsst-sqre/buildbot-scripts.git'),
  $buildbot_branch   = hiera('lsststack::lsstsw::buildbot_branch',
                              'master'),
  $buildbot_ensure   = hiera('lsststack::lsstsw::buildbot_ensure',
                              'present'),
  $lsst_build_repo   = hiera('lsststack::lsstsw::lsst_build_repo',
                              'https://github.com/lsst/lsst_build.git'),
  $lsst_build_branch = hiera('lsststack::lsstsw::lsst_build_branch',
                              'master'),
  $lsst_build_ensure = hiera('lsststack::lsstsw::lsst_build_ensure',
                              'present'),
  $debug             = false,
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
  validate_re($lsstsw_ensure, ['^present$', '^latest$'])
  validate_string($buildbot_repo)
  validate_string($buildbot_branch)
  validate_re($buildbot_ensure, ['^present$', '^latest$'])
  validate_string($lsst_build_repo)
  validate_string($lsst_build_branch)
  validate_re($lsst_build_ensure, ['^present$', '^latest$'])
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
  $lsst_build = "${lsstsw}/lsst_build"
  $buildbot = "${home}/buildbot-scripts"

  # afwdata git bundle download hack
  $afwdata_s3     = 'http://lsst-repos.s3.amazonaws.com/afwdata.bundle'
  $afwdata_bundle = "${home}/afwdata.bundle"
  $afwdata_clone  = "${lsstsw}/build/afwdata"
  $afwdata_repo   = 'git://git.lsstcorp.org/LSST/DMS/testdata/afwdata.git'

  vcsrepo { $lsstsw:
    ensure   => $lsstsw_ensure,
    provider => git,
    user     => $user,
    group    => $group,
    source   => $lsstsw_repo,
    revision => $lsstsw_branch,
  }

  vcsrepo { $buildbot:
    ensure   => $buildbot_ensure,
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
    user        => $user,
    timeout     => 3600,
    require     => $deploy_deps,
  }

  # deploy will delete the lsst_build directory if it already exists so we need
  # to manage the repo after deploy has completed
  vcsrepo { $lsst_build:
    ensure   => $lsst_build_ensure,
    provider => git,
    user     => $user,
    group    => $group,
    source   => $lsst_build_repo,
    revision => $lsst_build_branch,
    require  => Exec['deploy'],
  }

  exec { 'afwdata_clone':
    command => "git clone -b master ${afwdata_bundle} ${afwdata_clone}",
    path    => ["${lsstsw}/lfs/bin", '/bin', '/usr/bin'],
    cwd     => $home,
    creates => $afwdata_clone,
    user    => $user,
    timeout => 3600,
    require => [
      Wget::Fetch[$afwdata_bundle],
      Exec['deploy'],
    ],
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
    subscribe   => [
      Exec['deploy'],
      Vcsrepo[$lsst_build],
    ],
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
