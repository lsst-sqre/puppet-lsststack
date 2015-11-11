# == Class: lsststack
#
class lsststack(
  $install_dependencies = $::lsststack::params::install_dependencies,
  $install_convenience  = $::lsststack::params::install_convenience,
) inherits lsststack::params {

  validate_bool($install_dependencies)
  validate_bool($install_convenience)

  if $install_dependencies {
    Anchor['lsststack::begin'] ->
      class { 'lsststack::dependencies': } ->
        Anchor['lsststack::end']
  }

  if $install_convenience {
    Anchor['lsststack::begin'] ->
      class { 'lsststack::convenience': } ->
        Anchor['lsststack::end']
  }

  anchor { 'lsststack::begin': } ->
  anchor { 'lsststack::end': }
}
