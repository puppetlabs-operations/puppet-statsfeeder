require 'spec_helper'
describe 'statsfeeder' do

  context 'with defaults for all parameters' do
    it { should contain_class('statsfeeder') }
  end
end
