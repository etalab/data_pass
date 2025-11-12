require 'rails_helper'

RSpec.describe WebhookCall do
  it 'has a valid factory' do
    expect(build(:webhook_call)).to be_valid
  end
end
