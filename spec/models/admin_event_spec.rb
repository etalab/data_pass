require 'rails_helper'

RSpec.describe AdminEvent do
  it 'has valid factory' do
    expect(build(:admin_event)).to be_valid
  end
end
