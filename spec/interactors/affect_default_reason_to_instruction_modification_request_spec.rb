RSpec.describe AffectDefaultReasonToInstructionModificationRequest, type: :interactor do
  subject(:instructor_modification_request_reason) { described_class.call(instructor_modification_request:).instructor_modification_request.reason }

  let(:instructor_modification_request) { authorization_request.modification_requests.build }

  describe 'with an authorization request kind with a custom default reason' do
    let(:authorization_request) { create(:authorization_request, :hubee_cert_dc) }

    it 'affects it' do
      expect(instructor_modification_request_reason).to include('Maire')
    end
  end

  describe 'without an authorization request kind with a custom default reason' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise) }

    it 'does not affect any default reason' do
      expect(instructor_modification_request_reason).to be_blank
    end
  end
end
