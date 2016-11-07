# == Class: lsststack::repos
#
# this class should be considered private
class lsststack::repos {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
}
