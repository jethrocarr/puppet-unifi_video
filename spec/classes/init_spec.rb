require 'spec_helper'
describe 'unifi_video' do

  context 'with defaults for all parameters' do
    it { should contain_class('unifi_video') }
  end
end
