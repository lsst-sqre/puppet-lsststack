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

  exec { 'deploy':
    command     => "${lsstsw}/bin/deploy",
    path        => ['/bin', '/usr/bin'],
    environment => ["LSSTSW=${lsstsw}"],
    creates     => "${lsstsw}/lfs/bin/numdiff",
    user        => $user,
    timeout     => 3600,
    require     => [
      Vcsrepo[$lsstsw],
      Vcsrepo[$buildbot],
    ],
  }

  # `lsst_build prepare` commits the build manifest to versiondb and git will
  # exit with a status of 128 if an author is not set.
  $git_config = "${lsstsw}/versiondb/.git/config"
  $git_name   = 'LSST DATA Management'
  $git_email  = 'dm-devel@lists.lsst.org'

  exec { 'user.name':
    command => "git config -f ${git_config} user.name \"${git_name}\"",
    path    => ["${lsstsw}/lfs/bin", '/bin', '/usr/bin'],
    cwd     => $home,
    user    => $user,
    unless  => "grep -q '${git_name}' ${git_config}",
    require => Exec['deploy'],
  }

  exec { 'user.email':
    command => "git config -f ${git_config} user.email \"${git_email}\"",
    path    => ["${lsstsw}/lfs/bin", '/bin', '/usr/bin'],
    cwd     => $home,
    user    => $user,
    unless  => "grep -q '${git_email}' ${git_config}",
    require => Exec['deploy'],
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
    require     => [
      Exec['user.name'],
      Exec['user.email'],
    ],
    subscribe   => [
      Exec['deploy'],
      Vcsrepo[$lsst_build],
    ],
  }

}
