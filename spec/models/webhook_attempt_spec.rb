require 'rails_helper'

RSpec.describe WebhookAttempt do
  it 'has a valid factory' do
    expect(build(:webhook_attempt)).to be_valid
  end
end
