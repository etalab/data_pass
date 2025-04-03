require 'rails_helper'

RSpec.describe BulkAuthorizationRequestUpdate do
  it 'has a valid factory' do
    expect(build(:bulk_authorization_request_update)).to be_valid
  end

  it 'validates existence of authorization definition' do
    expect(build(:bulk_authorization_request_update, authorization_definition_uid: 'nope')).not_to be_valid
  end
end
