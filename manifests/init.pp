# == Class: lsststack
#
class lsststack(
  $install_dependencies = $::lsststack::params::install_dependencies,
  $manage_repos         = $::lsststack::params::manage_repos,
  $install_convenience  = $::lsststack::params::install_convenience,
) inherits lsststack::params {

  validate_bool($install_dependencies)
  validate_bool($manage_repos)
  validate_bool($install_convenience)

  if $install_dependencies {
    Anchor['lsststack::begin']
      -> class { 'lsststack::dependencies': }
        -> Anchor['lsststack::end']
  }

  if $manage_repos {
    Anchor['lsststack::begin']
      -> class { 'lsststack::repos': }
        -> Anchor['lsststack::end']

    if $install_dependencies {
      Class['lsststack::repos']
        -> Class['lsststack::dependencies']
    }
  }

  if $install_convenience {
    Anchor['lsststack::begin']
      -> class { 'lsststack::convenience': }
        -> Anchor['lsststack::end']
  }

  anchor { 'lsststack::begin': }
    -> anchor { 'lsststack::end': }
}
