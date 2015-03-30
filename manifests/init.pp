# == Class: lsststack
#
# simple template
#
# === Examples
#
# include lsststack
#
class lsststack inherits lsststack::params {

anchor { 'lsststack::begin': } ->
class { 'lsststack::dependencies': } ->
anchor { 'lsststack::end': }
}
