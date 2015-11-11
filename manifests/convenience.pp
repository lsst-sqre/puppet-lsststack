# == Class: lsststack::convenience
#
# this class should be considered private
class lsststack::convenience {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  ensure_packages($::lsststack::convenience_packages)
}
