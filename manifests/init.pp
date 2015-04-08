# == Class: lsststack
#
class lsststack(
  $install_dependencies = $::lsststack::params::install_dependencies,
) inherits lsststack::params {

  validate_bool($install_dependencies)

  if $install_dependencies {
    Anchor['lsststack::begin'] ->
      class { 'lsststack::dependencies': } ->
        Anchor['lsststack::end']
  }

  anchor { 'lsststack::begin': } ->
  anchor { 'lsststack::end': }
}
