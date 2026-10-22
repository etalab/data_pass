RSpec.describe API::V1::AuthorizationDefinitionSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:consentements) { described_class.new(definition).serializable_hash[:consentements] }

    context 'with a type that requires terms of service and data protection officer information' do
      let(:definition) { AuthorizationDefinition.find('api_entreprise') }

      it { is_expected.to eq(%i[terms_of_service_accepted data_protection_officer_informed]) }
    end

    context 'with a type that has an extra checkbox' do
      let(:definition) { AuthorizationDefinition.all.find { |definition| definition.authorization_request_class == AuthorizationRequest::APIR2P } }

      it { is_expected.to include(:dpd_homologation_checkbox) }
    end
  end
end
