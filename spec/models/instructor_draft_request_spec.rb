require 'rails_helper'

RSpec.describe InstructorDraftRequest do
  it 'has valid factories' do
    expect(build(:instructor_draft_request)).to be_valid
  end

  describe 'instructor validation' do
    subject { build(:instructor_draft_request, authorization_request_class:, instructor:) }

    let(:authorization_request_class) { 'AuthorizationRequest::APIEntreprise' }
    let(:instructor) { create(:user, :instructor, authorization_request_types:) }

    context 'with instructor for authorization request class' do
      let(:authorization_request_types) { %w[api_entreprise] }

      it { is_expected.to be_valid }
    end

    context 'with another instructor' do
      let(:authorization_request_types) { %w[whatever] }

      it { is_expected.not_to be_valid }
    end
  end
end
