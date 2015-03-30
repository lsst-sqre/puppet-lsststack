# == Class: lsststack::dependencies
#
# this class should be considered private
class lsststack::dependencies {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  ensure_packages($::lsststack::dependency_packages)
}
