require 'rails_helper'

RSpec.describe BulkAuthorizationRequestUpdate, type: :model do
  it 'has a valid factory' do
    expect(build(:bulk_authorization_request_update)).to be_valid
  end

  it 'validates existence of authorization definition' do
    expect(build(:bulk_authorization_request_update, authorization_definition_uid: 'nope')).to be_invalid
  end
end
