# == Define: lsststack::newinstall
#
define lsststack::newinstall(
  $user         = $title,
  $group        = $title,
  $manage_user  = true,
  $manage_group = true,
  $stack_path   = undef,
  $source       = hiera('lsststack::newinstall::source',
                        'https://sw.lsstcorp.org/eupspkg/newinstall.sh'),
  $debug        = false,
) {
  include ::wget

  Class[lsststack] -> Lsststack::Newinstall[$title]

  validate_string($user)
  validate_string($group)
  validate_bool($manage_user)
  validate_bool($manage_group)
  if $stack_path { validate_absolute_path($stack_path) }
  validate_string($source)
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

  $real_stack_path = $stack_path ? {
    undef   => "${home}/stack",
    default => $stack_path,
  }

  file { 'stack':
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
    path   => $real_stack_path,
  }

  wget::fetch { 'newinstall.sh':
    source      => $source,
    destination => "${real_stack_path}/newinstall.sh",
    execuser    => $user,
    timeout     => 60,
    verbose     => false,
    require     => File['stack'],
  }

  file { 'newinstall.sh':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    path    => "${real_stack_path}/newinstall.sh",
    require => Wget::Fetch['newinstall.sh'],
  }

  exec { 'newinstall.sh':
    environment => ["PWD=${real_stack_path}"],
    command     => 'if grep -q -i "CentOS release 6" /etc/redhat-release; then
      . /opt/rh/devtoolset-3/enable
    fi
    newinstall.sh -b',
    path        => ['/bin', '/usr/bin', $real_stack_path],
    cwd         => $real_stack_path,
    user        => $user,
    logoutput   => true,
    creates     => "${real_stack_path}/loadLSST.bash",
    timeout     => 900,
    provider    => 'shell',
    require     => File['newinstall.sh'],
  }
}
