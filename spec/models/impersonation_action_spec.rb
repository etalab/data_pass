require 'rails_helper'

RSpec.describe ImpersonationAction do
  it 'has a valid factory' do
    expect(build(:impersonation_action)).to be_valid
  end
end
