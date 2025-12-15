require 'rails_helper'

RSpec.describe InstructorDraftRequestDocument do
  it 'has valid factories' do
    expect(build(:instructor_draft_request_document)).to be_valid
  end
end
