require 'rails_helper'

RSpec.describe HubEECertDCBridge do
  let(:authorization_request) { create(:authorization_request, :validated, :portail_hubee_demarche_certdc).decorate }
  let(:administrateur_metier) { authorization_request.contact_data_by_type(:administrateur_metier) }
  let(:siret) { authorization_request.organization[:siret] }
  let(:updated_at) { authorization_request[:updated_at] }
  let(:validated_at) { authorization_request.last_validated_at }
  let(:scope) { 'CERTDC' }
  let(:authorization_id) { authorization_request.authorizations.last.id }
  let(:etablissement_data) do
    {
      'statutDiffusionEtablissement' => 'O',
      'periodesEtablissement' => [{ 'etatAdministratifEtablissement' => 'A', 'activitePrincipaleEtablissement' => '62.01Z' }],
      'uniteLegale' => { 'denominationUniteLegale' => 'My Company', 'sigleUniteLegale' => 'MC' },
      'adresseEtablissement' => {
        'numeroVoieEtablissement' => '10',
        'libelleVoieEtablissement' => 'Rue Example',
        'codePostalEtablissement' => '75001',
        'codeCommuneEtablissement' => '75101',
        'libelleCommuneEtablissement' => 'Paris'
      },
      'uniteLegale' => {
        'categorieJuridiqueUniteLegale' => '1000'
      }
    }
  end
  let(:etablissement_response) { { 'etablissement' => etablissement_data } }
  let(:http_instance) { instance_double(Http) }
  let(:hubee_configuration) { { host: 'http://api.example.com', auth_url: 'http://auth.example.com', client_id: 'client_id', client_secret: 'client_secret' } }
  let(:token_response) { double('Response', parse: { 'access_token' => 'access_token' }) }
  let(:subscription_response) { double('Response', parse: { 'id' => 1 }) }

  before do
    allow(INSEESireneAPIClient).to receive(:new).and_return(double('INSEESireneAPIClient', etablissement: etablissement_response))
    allow(Http).to receive(:instance).and_return(http_instance)
    allow(Rails.application.credentials).to receive(:hubee).and_return(hubee_configuration)
    allow(http_instance).to receive(:post).and_return(token_response, subscription_response)
    allow(http_instance).to receive(:get).and_raise(NameError.new(404, 'Not Found'))
  end

  describe '#perform' do
    let(:bridge) { described_class.new(authorization_request) }

    it 'sends the correct payloads to Http.instance.post and Http.instance.get' do
      bridge.perform

      # Token request
      expect(http_instance).to have_received(:post).with(hash_including(
        url: hubee_configuration[:auth_url],
        body: { grant_type: 'client_credentials', scope: 'ADMIN' },
        api_key: Base64.strict_encode64("#{hubee_configuration[:client_id]}:#{hubee_configuration[:client_secret]}"),
        use_basic_auth_method: true,
        tag: 'Portail HubEE'
      ))

      # Organization request
      expect(http_instance).to have_received(:get).with(hash_including(
        url: "#{hubee_configuration[:host]}/referential/v1/organizations/SI-#{siret}-75101",
        api_key: 'access_token',
        tag: 'Portail HubEE'
      ))

      # Organization creation
      expect(http_instance).to have_received(:post).with(hash_including(
        url: "#{hubee_configuration[:host]}/referential/v1/organizations",
        body: {
          type: 'SI',
          companyRegister: siret,
          branchCode: '75101',
          name: nil,
          code: nil,
          country: 'France',
          postalCode: '75001',
          territory: 'Paris',
          email: 'jean.dupont.administrateur_metier@gouv.fr',
          phoneNumber: '0836656565',
          status: 'Actif'
        },
        api_key: 'access_token',
        tag: 'Portail HubEE'
      ))

      # Subscription creation
      expect(http_instance).to have_received(:post).with(hash_including(
        url: "#{hubee_configuration[:host]}/referential/v1/subscriptions",
        body: {
          datapassId: authorization_id,
          processCode: scope,
          subscriber: {
            type: 'SI',
            companyRegister: siret,
            branchCode: '75101'
          },
          accessMode: nil,
          notificationFrequency: 'unitaire',
          activateDateTime: nil,
          validateDateTime: validated_at.iso8601,
          rejectDateTime: nil,
          endDateTime: nil,
          updateDateTime: updated_at.iso8601,
          delegationActor: nil,
          rejectionReason: nil,
          status: 'Inactif',
          email: administrateur_metier[:email],
          localAdministrator: {
            email: administrateur_metier[:email],
            firstName: administrateur_metier[:given_name],
            lastName: administrateur_metier[:family_name],
            function: administrateur_metier[:job_title],
            phoneNumber: administrateur_metier[:phone_number].delete(' ').delete('.').delete('-'),
            mobileNumber: nil
          }
        },
        api_key: 'access_token',
        tag: 'Portail HubEE'
      ))
    end
  end
end
