require 'spec_helper'

describe 'lsststack', :type => :class do

  describe 'for osfamily RedHat' do
    it { should contain_class('lsststack') }
  end

end
