RSpec.describe AssignConsentsToAuthorizationRequest, type: :interactor do
  subject(:result) { described_class.call(authorization_request:, consentement:) }

  let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

  before do
    authorization_request.update!(terms_of_service_accepted: false, data_protection_officer_informed: false)
  end

  context 'when every consent is given' do
    let(:consentement) do
      ActionController::Parameters.new(terms_of_service_accepted: true, data_protection_officer_informed: 'true')
    end

    it { is_expected.to be_success }

    it 'checks every consent required by the authorization request' do
      result

      expect(authorization_request.terms_of_service_accepted).to be(true)
      expect(authorization_request.data_protection_officer_informed).to be(true)
    end
  end

  context 'when a consent is refused' do
    let(:consentement) do
      ActionController::Parameters.new(terms_of_service_accepted: true, data_protection_officer_informed: false)
    end

    it 'does not check it' do
      result

      expect(authorization_request.terms_of_service_accepted).to be(true)
      expect(authorization_request.data_protection_officer_informed).to be(false)
    end
  end

  context 'when a consent is missing' do
    let(:consentement) { ActionController::Parameters.new(terms_of_service_accepted: true) }

    it 'does not check it' do
      result

      expect(authorization_request.data_protection_officer_informed).to be(false)
    end
  end
end
