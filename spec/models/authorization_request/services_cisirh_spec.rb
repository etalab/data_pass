RSpec.describe AuthorizationRequest::ServicesCisirh do
  describe 'technical contact error messages' do
    let(:authorization_request) { build(:authorization_request, :services_cisirh) }

    before do
      authorization_request.valid?(:submit)
    end

    it 'names the technical contact RSSI' do
      expect(authorization_request.errors.full_messages_for(:contact_technique_email)).to include(a_string_starting_with('Email du RSSI'))
    end

    it 'never mentions the technical contact wording' do
      expect(authorization_request.errors.full_messages.join).not_to include('contact technique')
    end
  end

  describe 'other forms' do
    it 'keep the technical contact wording' do
      expect(AuthorizationRequest::APIParticulier.human_attribute_name(:contact_technique_email)).to eq('Email du contact technique')
    end
  end
end
