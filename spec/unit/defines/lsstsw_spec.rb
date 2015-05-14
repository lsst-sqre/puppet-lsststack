require 'spec_helper'

describe 'lsststack::lsstsw', :type => :define do
  let(:facts) {{ :osfamily => 'RedHat', :operatingsystemmajrelease => 6 }}
  let(:name) { 'foo' }
  let(:title) { name }
  let(:pre_condition) { 'include ::lsststack' }

  describe 'parameters' do
    context '(all unset)' do
      it { should compile.with_all_deps }
      it do
        should contain_lsststack__lsstsw(name).
          that_requires('Class[lsststack]')
      end
      it { should contain_class('wget') }
      it do
        should contain_user(name).with(
          :ensure     => 'present',
          :gid        => name,
          :managehome => true,
          :shell      => '/bin/bash'
        )
      end
      it do
        should contain_group(name).with(
          :ensure => 'present'
        )
      end
      it do
        should contain_vcsrepo("/home/#{name}/lsstsw").with(
          :ensure   => 'present',
          :provider => 'git',
          :user     => name,
          :group    => name,
          :revision => 'master'
        )
      end
      it do
        should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
          :ensure   => 'present',
          :provider => 'git',
          :user     => name,
          :group    => name,
          :revision => 'master'
        )
      end
      it do
        should contain_wget__fetch("/home/#{name}/afwdata.bundle").with(
          :destination => "/home/#{name}/afwdata.bundle",
          :execuser    => name,
          :timeout     => 3600,
          :verbose     => false
        ).without_cache_dir
      end
      it do
        should contain_file('.gitconfig').with(
          :ensure  => 'file',
          :owner   => name,
          :group   => name,
          :mode    => '0664',
          :path    => "/home/#{name}/.gitconfig",
          :content => <<-EOS
[user]
	name = LSST Data Management
	email = dm-devel@lists.lsst.org
EOS
        )
      end
      it do
        should contain_exec('deploy').with(
          :creates => "/home/#{name}/lsstsw/lfs/bin/numdiff"
        ).that_requires([
          "Vcsrepo[/home/#{name}/lsstsw]",
          "Vcsrepo[/home/#{name}/buildbot-scripts]",
          'File[.gitconfig]'
        ])
      end
      it do
        should contain_exec('afwdata_clone').with(
          :command => "git clone -b master /home/#{name}/afwdata.bundle /home/#{name}/lsstsw/build/afwdata",
          :path    => ["/home/#{name}/lsstsw/lfs/bin", '/bin', '/usr/bin'],
          :cwd     => "/home/#{name}",
          :creates => "/home/#{name}/lsstsw/build/afwdata",
          :user    => name,
          :timeout => 3600
        ).that_requires([
          "Exec[deploy]",
          "Wget::Fetch[/home/#{name}/afwdata.bundle]",
        ])
      end
      it do
        should contain_exec('git remote rm origin').
          that_requires('Exec[afwdata_clone]')
      end
      it do
        should contain_exec('git remote add origin').
          that_requires('Exec[git remote rm origin]')
      end
      it do
        should contain_exec('git pull origin master').
          that_requires('Exec[git remote add origin]')
      end
      it do
        should contain_exec('git branch --set-upstream-to=origin/master').
          that_requires('Exec[git pull origin master]')
      end
      it do
        should contain_exec('rebuild -p').
          that_requires('Exec[git branch --set-upstream-to=origin/master]')
      end
    end # default params

    context 'user =>' do
      context '(unset)' do
        it { should contain_lsststack__lsstsw(name).with(:user => name) }
        it { should contain_user(name) }
      end

      context 'larry' do
        let(:params) {{ :user => 'larry' }}

        it { should contain_user('larry') }
      end

      context '[]' do
        let(:params) {{ :user => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # user =>

    context 'group =>' do
      context '(unset)' do
        it { should contain_lsststack__lsstsw(name).with(:group => name) }
        it { should contain_group(name) }
      end

      context 'larry' do
        let(:params) {{ :group => 'larry' }}

        it { should contain_group('larry') }
      end

      context '[]' do
        let(:params) {{ :group => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # group =>

    context 'manage_user =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(:manage_user => true)
        end
        it { should contain_user(name) }
      end

      context 'true' do
        let(:params) {{ :manage_user => true }}

        it { should contain_user(name) }
      end

      context 'false' do
        let(:params) {{ :manage_user => false }}

        it { should_not contain_user(name) }
      end

      context 'bar' do
        let(:params) {{ :manage_user => 'bar' }}

        it { should raise_error(Puppet::Error, /is not a bool/) }
      end
    end # manage_user =>

    context 'manage_group =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(:manage_group => true)
        end
        it { should contain_group(name) }
      end

      context 'true' do
        let(:params) {{ :manage_group => true }}

        it { should contain_group(name) }
      end

      context 'false' do
        let(:params) {{ :manage_group => false }}

        it { should_not contain_group(name) }
      end

      context 'bar' do
        let(:params) {{ :manage_group => 'bar' }}

        it { should raise_error(Puppet::Error, /is not a bool/) }
      end
    end # manage_group =>

    context 'lsstsw_repo =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :lsstsw_repo => 'https://github.com/lsst/lsstsw.git'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :source => 'https://github.com/lsst/lsstsw.git'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :lsstsw_repo => 'bar' }}

        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :source => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :lsstsw_repo => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # lsstsw_repo =>

    context 'lsstsw_branch =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :lsstsw_branch => 'master'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :revision => 'master'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :lsstsw_branch => 'bar' }}

        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :revision => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :lsstsw_branch => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # lsstsw_branch =>

    context 'buildbot_repo =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :buildbot_repo => 'https://github.com/lsst-sqre/buildbot-scripts.git'
          )
end
        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :source => 'https://github.com/lsst-sqre/buildbot-scripts.git'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :buildbot_repo => 'bar' }}

        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :source => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :buildbot_repo => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # buildbot_repo =>

    context 'buildbot_branch =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :buildbot_branch => 'master'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :revision => 'master'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :buildbot_branch => 'bar' }}

        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :revision => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :buildbot_branch => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # buildbot_branch =>

    context 'debug =>' do
      context '(unset)' do
        it { should contain_lsststack__lsstsw(name).with(:debug => false) }
      end

      context 'true' do
        let(:params) {{ :debug => true }}

        it { should_not raise_error }
      end

      context 'false' do
        let(:params) {{ :debug => false }}

        it { should_not raise_error }
      end

      context 'bar' do
        let(:params) {{ :debug => 'bar' }}

        it { should raise_error(Puppet::Error, /is not a bool/) }
      end
    end # debug =>
  end # on osfamily RedHat
end
