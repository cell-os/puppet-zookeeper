require 'spec_helper'
describe 'zookeeper' do

  context 'with defaults for all parameters' do
    it { should contain_class('zookeeper') }
  end
end
