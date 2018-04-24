require 'spec_helper'

describe 'lsststack', :type => :class do
  let(:el_deps) {[
    'bison',
    'blas',
    'bzip2-devel',
    'bzip2', # needed on el7 -- pulled in by bzip2-devel on el6?
    'curl',
    'flex',
    'fontconfig',
    'freetype-devel',
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
    'which',
    'sed',
    'gawk',
  ]}
  let(:el_con) {[
    'screen',
    'tmux',
    'tree',
    'vim-enhanced',
    'emacs-nox'
  ]}
  let(:el_cc) {[
    'gcc-c++',
    'gcc-gfortran',
  ]}
  let (:debian_deps) {[
    'make',
    # list from https://confluence.lsstcorp.org/display/LSWUG/Prerequisites
    'bison',
    'ca-certificates', # needed by curl on ubuntu
    'curl',
    'flex',
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
  ]}
  let (:debian_con) {[
    'screen',
    'tmux',
    'tree',
    'vim',
    'emacs-nox'
  ]}
  let (:debian_cc) {[
    'g++',
  ]}

  describe 'for osfamily RedHat' do
    let(:facts) {{ :osfamily => 'RedHat' }}

    it { el_deps.each { |pkg| should contain_package(pkg) } }
    it { el_con.each { |pkg| should_not contain_package(pkg) } }
    it { el_cc.each { |pkg| should_not contain_package(pkg) } }

    context 'install_dependencies =>' do
      context 'true' do
        let(:params) {{ :install_dependencies => true }}

        context 'operatingsystemmajrelease => 6' do
          before { facts[:operatingsystemmajrelease] = '6' }
          it { el_deps.each { |pkg| should contain_package(pkg) } }
        end
        context 'operatingsystemmajrelease => 7' do
          before { facts[:operatingsystemmajrelease] = '7' }
          it { el_deps.each { |pkg| should contain_package(pkg) } }
        end
      end

      context 'false' do
        let(:params) {{ :install_dependencies => false }}

        it { el_deps.each { |pkg| should_not contain_package(pkg) } }
      end

      context '[]' do
        let(:params) {{ :install_dependencies => []}}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not a boolean/)
        end
      end
    end # install_dependencies =>

    context 'manage_repos =>' do
      context 'true' do
        let(:params) {{ :manage_repos => true }}

        # class is empty after refactoring
        it { should contain_class('lsststack::repos') }
      end

      context 'false' do
        let(:params) {{ :manage_repos => false }}

        # testing for the class only in the negative case as rspec-puppet
        # doesn't currently allow us to express the catalog should not have
        # *any* yumrepo resources
        it { should_not contain_class('lsststack::repos') }
      end

      context '[]' do
        let(:params) {{ :manage_repos => []}}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not a boolean/)
        end
      end
    end # manage_repos =>

    context 'install_convenience =>' do
      context 'true' do
        let(:params) {{ :install_convenience => true }}

        it { el_con.each { |pkg| should contain_package(pkg) } }
      end

      context 'false' do
        let(:params) {{ :install_convenience => false }}

        it { el_con.each { |pkg| should_not contain_package(pkg) } }
      end

      context '[]' do
        let(:params) {{ :install_convenience => []}}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not a boolean/)
        end
      end
    end # install_convenience =>

    context 'install_cc =>' do
      context 'true' do
        let(:params) {{ :install_cc => true }}

        it { el_cc.each { |pkg| should contain_package(pkg) } }
      end

      context 'false' do
        let(:params) {{ :install_cc => false }}

        it { el_cc.each { |pkg| should_not contain_package(pkg) } }
      end

      context '[]' do
        let(:params) {{ :install_cc => []}}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not a boolean/)
        end
      end
    end # install_convenience =>
  end # for osfamily RedHat

  describe 'for osfamily Debian' do
    let(:facts) {{ :osfamily => 'Debian' }}

    it { debian_deps.each { |pkg| should contain_package(pkg) } }
    it { debian_con.each { |pkg| should_not contain_package(pkg) } }
    it { debian_cc.each { |pkg| should_not contain_package(pkg) } }
  end # for osfamily Debian
end
