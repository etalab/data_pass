require 'rails_helper'

RSpec.describe Webhook do
  it 'has a valid factory' do
    expect(build(:webhook)).to be_valid
  end
end
