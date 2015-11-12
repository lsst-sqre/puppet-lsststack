require 'spec_helper'
require 'yaml'

# hiera values get "cached" and reused even after hiera_config is changed /
# unset and will break other spec tests.
#
# https://github.com/rodjek/rspec-puppet/issues/215
module RSpec::Puppet
  module Support
    def build_catalog(*args)
      @@cache[args] = self.build_catalog_without_cache(*args)
    end
  end
end

describe 'lsststack::lsstsw', :type => :define do
  before(:all) do
    RSpec.configure do |c|
      c.hiera_config = fixtures('hiera/hiera.yaml')
    end
  end

  after(:all) do
    RSpec.configure do |c|
      c.hiera_config = '/dev/null'
    end
  end

  let(:facts) {{ :osfamily => 'RedHat', :operatingsystemmajrelease => '6' }}
  let(:name) { 'foo' }
  let(:title) { name }
  let(:pre_condition) { 'include ::lsststack' }

  context 'hiera' do
    hiera_params = YAML.load(File.read(fixtures('hieradata/lsstsw.yaml')))
    # strip lsststack::lsstsw:: namespace from hash keys in the hiera yaml
    # file.
    hiera_params.keys.each do |k|
      hiera_params[k.sub(/^lsststack::lsstsw::/, '').to_sym] =
        hiera_params.delete(k)
    end

    context 'data overrides parameters defaults' do
      hiera_params.each_pair do |k,v|
        it { should contain_lsststack__lsstsw(name).with( k => v ) }
      end
    end # data overrides parameters defaults

    context 'parameters have precedence over data' do
      define_params = hiera_params.dup
      # convert 'latest' values to 'present' and prefix all other values with
      # 'p'
      define_params.each_pair do |k,v|
        newv = nil
        if v == 'latest'
          newv = 'present'
        else
          newv = "p#{v}"
        end

        define_params[k] = newv
      end

      let(:params) {define_params}

      define_params.each_pair do |k,v|
        it { should contain_lsststack__lsstsw(name).with( k => v ) }
      end
    end # parameters have precedence over data
  end # hiera
end
