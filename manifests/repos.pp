# == Class: lsststack::repos
#
# this class should be considered private
class lsststack::repos {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::osfamily == 'RedHat' {
    if $::operatingsystemmajrelease == '6' {
      $epel = $::operatingsystemmajrelease ? {
        '6'     => 'epel-6-x86_64',
        default => undef,
      }

      yumrepo { "rhscl-devtoolset-3-${epel}":
        ensure   => 'present',
        baseurl  => "https://www.softwarecollections.org/repos/rhscl/devtoolset-3/${epel}",
        descr    => "Devtoolset-3 - ${epel}",
        enabled  => '1',
        gpgcheck => '0',
      }

      Yumrepo["rhscl-devtoolset-3-${epel}"] -> Package<| provider == 'yum' |>
    }
  }

}
