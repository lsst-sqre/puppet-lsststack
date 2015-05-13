require 'spec_helper_acceptance'

describe 'lsststack::lsstsw define' do
  describe 'running puppet code' do
    pp = <<-EOS
      if $::osfamily == 'RedHat' {
        class { 'epel': } -> Class['lsststack']
      }

      include ::lsststack
      lsststack::lsstsw { 'build0': }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
