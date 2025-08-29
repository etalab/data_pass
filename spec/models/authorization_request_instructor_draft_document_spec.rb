require 'rails_helper'

RSpec.describe AuthorizationRequestInstructorDraftDocument do
  it 'has valid factories' do
    expect(build(:authorization_request_instructor_draft_document)).to be_valid
  end
end
