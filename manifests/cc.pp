# == Class: lsststack::cc
#
# this class should be considered private
class lsststack::cc {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  ensure_packages($::lsststack::cc_packages)
}
