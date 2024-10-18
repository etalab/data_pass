RSpec.describe HubEEDilaBridge do
  describe '#perform on approve' do
    subject(:hubee_dila_bridge) { described_class.perform_now(authorization_request, 'approve') }

    let(:authorization_request) { create(:authorization_request, :hubee_dila, :validated, organization:, scopes: %w[etat_civil depot_dossier_pacs]) }
    let(:organization) { create(:organization, siret: '21920023500014') }

    let(:organization_payload) { build(:hubee_organization_payload, organization:, authorization_request:) }
    let(:subscription_response) { build(:hubee_subscription_response_payload, id: hubee_subscription_id) }
    let(:hubee_subscription_id) { '1234567890' }
    let(:etat_civil_and_depot_dossier_pacs_tokens) { { depot_dossier_pacs: hubee_subscription_id, etat_civil: hubee_subscription_id }.to_json }

    include_examples 'with mocked hubee API client'

    include_examples 'organization creation in hubee on approve'

    describe 'subscription creation' do
      it 'creates a subscription on HubEE linked to DataPass ID and a process code for each scope' do
        %w[EtatCivil depotDossierPACS].each do |process_code|
          expect(hubee_api_client).to receive(:create_subscription).with(
            hash_including(
              datapassId: authorization_request.id,
              processCode: process_code
            )
          )
        end

        hubee_dila_bridge
      end

      it 'sends the data to create a local administrator in HubEE' do
        expect(hubee_api_client).to receive(:create_subscription).with(
          hash_including(
            localAdministrator: {
              email: 'jean.dupont.administrateur_metier@gouv.fr',
              firstName: 'Jean Administrateur metier',
              lastName: 'Dupont Administrateur metier',
              function: 'Agent Administrateur metier',
              phoneNumber: '0836656565',
            }
          )
        ).twice

        hubee_dila_bridge
      end

      it 'does not create a subscription on HubEE for the other scopes' do
        other_codes = (HubEEDilaBridge::PROCESS_CODES.values - %w[EtatCivil depotDossierPACS])
        other_codes.each do |process_code|
          expect(hubee_api_client).not_to receive(:create_subscription).with(
            hash_including(processCode: process_code)
          )
        end

        hubee_dila_bridge
      end

      it 'stores all the HubEE subscription IDs in the external_provider_id' do
        hubee_dila_bridge

        expect(authorization_request.reload.external_provider_id).to eq(etat_civil_and_depot_dossier_pacs_tokens)
      end

      context 'with a reopened authorisation request with an added scope' do
        let(:authorization_request) { create(:authorization_request, :hubee_dila, :reopened, organization:, scopes: %w[etat_civil depot_dossier_pacs recensement_citoyen], external_provider_id: etat_civil_and_depot_dossier_pacs_tokens) }

        it 'creates a subscription on HubEE linked to DataPass ID and the process code of the added scope' do
          expect(hubee_api_client).to receive(:create_subscription).with(
            hash_including(
              datapassId: authorization_request.id,
              processCode: 'recensementCitoyen'
            )
          )

          hubee_dila_bridge
        end

        it 'does not create a subscription on HubEE for the other scopes' do
          other_codes = (HubEEDilaBridge::PROCESS_CODES.values - %w[recensementCitoyen])
          other_codes.each do |process_code|
            expect(hubee_api_client).not_to receive(:create_subscription).with(
              hash_including(processCode: process_code)
            )
          end

          hubee_dila_bridge
        end

        it 'stores all the HubEE subscription IDs in the external_provider_id' do
          hubee_dila_bridge

          expect(authorization_request.reload.external_provider_id).to eq({ depot_dossier_pacs: hubee_subscription_id, etat_civil: hubee_subscription_id, recensement_citoyen: hubee_subscription_id }.to_json)
        end
      end
    end
  end
end
