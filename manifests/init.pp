# == Class: lsststack
#
class lsststack(
  $manage_repos         = $::lsststack::params::manage_repos,
  $install_dependencies = $::lsststack::params::install_dependencies,
  $install_convenience  = $::lsststack::params::install_convenience,
  $install_cc           = $::lsststack::params::install_cc,
) inherits lsststack::params {

  validate_bool($manage_repos)
  validate_bool($install_dependencies)
  validate_bool($install_convenience)
  validate_bool($install_cc)

  if $manage_repos {
    Anchor['lsststack::begin']
      -> class { 'lsststack::repos': }
        -> Anchor['lsststack::end']

    if $install_dependencies {
      Class['lsststack::repos']
        -> Class['lsststack::dependencies']
    }

    if $install_convenience {
      Class['lsststack::repos']
        -> Class['lsststack::convenience']
    }

    if $install_cc {
      Class['lsststack::repos']
        -> Class['lsststack::cc']
    }
  }

  if $install_dependencies {
    Anchor['lsststack::begin']
      -> class { 'lsststack::dependencies': }
        -> Anchor['lsststack::end']
  }


  if $install_convenience {
    Anchor['lsststack::begin']
      -> class { 'lsststack::convenience': }
        -> Anchor['lsststack::end']
  }

  if $install_cc {
    Anchor['lsststack::begin']
      -> class { 'lsststack::cc': }
        -> Anchor['lsststack::end']
  }

  anchor { 'lsststack::begin': }
    -> anchor { 'lsststack::end': }
}
