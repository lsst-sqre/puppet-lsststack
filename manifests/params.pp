# == Class: lsststack::params
#
# this class should be considered private
class lsststack::params {
  $install_dependencies = true
  $manage_repos         = true
  $install_convenience  = false

  case $::osfamily {
    'Debian': {
      $dependency_packages = [
        # needed for newinstall.sh
        'make',
        # list from https://confluence.lsstcorp.org/display/LSWUG/Prerequisites
        'bison',
        'ca-certificates', # needed by curl on ubuntu
        'curl',
        'flex',
        'g++',
        'git',
        'libbz2-dev',
        'libgl1-mesa-swx11', # needed by conda qt / pyqt packages
        'libreadline6-dev',
        'libx11-dev',
        'libxt-dev',
        'm4',
        'zlib1g-dev',
        # needed for shapelet tests
        'libxrender1',
        'libfontconfig1',
        # needed by lua
        'libncurses5-dev',
        # needed for xrootd build
        'cmake',
        # needed for mysqlproxy
        'libglib2.0-dev',
        # needed to build zookeeper
        'default-jre',
        # needed to build git
        'gettext',
        'libcurl4-openssl-dev',
        'perl-modules',
      ]

      $convenience_packages = [
        'screen',
        'tmux',
        'tree',
        'vim',
        'emacs24-nox',
      ]
    }
    'RedHat': {
      $dependency_packages = [
        'bison',
        'blas',
        'bzip2-devel',
        'bzip2', # needed on el7 -- pulled in by bzip2-devel on el6?
        'curl',
        'flex',
        'fontconfig',
        'freetype-devel',
        'gcc-c++',
        'gcc-gfortran',
        'git', # needed on el6, in @core for others?
        'libuuid-devel',
        'libXext',
        'libXrender',
        'libXt-devel',
        'make',
        'mesa-libGL', # needed by conda qt / pyqt packages
        'openssl-devel',
        'patch',
        'perl',
        'readline-devel',
        'tar', # needed on el6, not part of @core or @base
        'zlib-devel',
        # needed by lua
        'ncurses-devel',
        # needed for xrootd build
        'cmake',
        # needed for mysqlproxy
        'glib2-devel',
        # needed to build zookeeper
        'java-1.8.0-openjdk',
        # needed to build git
        'gettext',
        'libcurl-devel',
        'perl-ExtUtils-MakeMaker',
      ]

      $convenience_packages = [
        'screen',
        'tmux',
        'tree',
        'vim-enhanced',
        'emacs-nox'
      ]
    }
    default: { fail() }
  }
}
