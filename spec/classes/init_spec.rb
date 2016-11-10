require 'spec_helper'
describe 'engine' do
  context 'with default values for all parameters' do
    it { should contain_class('engine') }
  end
end
