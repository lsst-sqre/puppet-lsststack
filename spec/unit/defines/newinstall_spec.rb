require 'spec_helper'

describe 'lsststack::newinstall', :type => :define do
  let(:facts) {{ :osfamily => 'RedHat', :operatingsystemmajrelease => '6' }}
  let(:name) { 'foo' }
  let(:title) { name }
  let(:pre_condition) { 'include ::lsststack' }

  describe 'parameters' do
    context '(all unset)' do
      it { should compile.with_all_deps }
      it do
        should contain_lsststack__newinstall(name).
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
        should contain_file('stack').with(
          :ensure => 'directory',
          :owner  => name,
          :group  => name,
          :mode   => '0755',
          :path   => "/home/#{name}/stack"
        )
      end
      it do
        should contain_wget__fetch('newinstall.sh').with(
          :source      => 'https://sw.lsstcorp.org/eupspkg/newinstall.sh',
          :destination => "/home/#{name}/stack/newinstall.sh",
          :execuser    => name,
          :timeout     => 60,
          :verbose     => false
        ).that_requires('File[stack]')
      end
      it do
        should contain_file('newinstall.sh').with(
          :ensure => 'file',
          :owner  => name,
          :group  => name,
          :mode   => '0755',
          :path   => "/home/#{name}/stack/newinstall.sh"
        ).that_requires('Wget::Fetch[newinstall.sh]')
      end
      it do
        should contain_exec('newinstall.sh').with(
          :environment => ["PWD=/home/#{name}/stack"],
          :command     => /newinstall.sh -b/,
          :path        => ['/bin', '/usr/bin', "/home/#{name}/stack"],
          :cwd         => "/home/#{name}/stack",
          :user        => name,
          :logoutput   => true,
          :creates     => "/home/#{name}/stack/loadLSST.bash",
          :provider    => 'shell'
        ).that_requires('File[newinstall.sh]')
      end
    end # default params

    context 'user =>' do
      context '(unset)' do
        it { should contain_lsststack__newinstall(name).with(:user => name) }
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
        it { should contain_lsststack__newinstall(name).with(:group => name) }
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
          should contain_lsststack__newinstall(name).with(:manage_user => true)
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
          should contain_lsststack__newinstall(name).with(:manage_group => true)
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

    context 'stack_path =>' do
      context '(unset)' do
        it do
          should contain_lsststack__newinstall(name).with(
            :stack_path => nil
          )
        end
        it do
          should contain_file('stack').with(
            :ensure => 'directory',
            :path   => "/home/#{name}/stack"
          )
        end
      end

      context '/dne' do
        let(:params) {{ :stack_path => '/dne' }}

        it do
          should contain_file('stack').with(
            :ensure => 'directory',
            :path   => "/dne"
          )
        end
      end

      context 'foo' do
        let(:params) {{ :stack_path => 'foo' }}

        it { should raise_error(Puppet::Error, /is not an absolute path/) }
      end
    end # stack_path =>

    context 'source =>' do
      context '(unset)' do
        it do
          should contain_lsststack__newinstall(name).with(
            :source => 'https://sw.lsstcorp.org/eupspkg/newinstall.sh'
          )
        end
        it do
          should contain_wget__fetch('newinstall.sh').with(
            :source => 'https://sw.lsstcorp.org/eupspkg/newinstall.sh'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :source => 'bar' }}

        it do
          should contain_wget__fetch('newinstall.sh').with(
            :source => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :source => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # source =>

    context 'debug =>' do
      context '(unset)' do
        it { should contain_lsststack__newinstall(name).with(:debug => false) }
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
