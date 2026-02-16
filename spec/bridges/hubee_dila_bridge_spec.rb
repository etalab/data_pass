RSpec.describe HubEEDilaBridge do
  describe '#perform on approve' do
    subject(:hubee_dila_bridge) { described_class.new.perform(authorization_request, 'approve') }

    let(:authorization_request) { create(:authorization_request, :hubee_dila, :validated, organization:, external_provider_id: nil, scopes: %w[etat_civil depot_dossier_pacs]) }
    let(:organization) { create(:organization, siret: '21920023500014') }

    let(:organization_payload) { build(:hubee_organization_payload, organization:, authorization_request:) }
    let(:subscription_response) { build(:hubee_subscription_response_payload, id: hubee_subscription_id) }
    let(:hubee_subscription_id) { '1234567890' }
    let(:etat_civil_and_depot_dossier_pacs_tokens) { { depot_dossier_pacs: hubee_subscription_id, etat_civil: hubee_subscription_id }.to_json }

    include_context 'with mocked hubee API client'
    it_behaves_like 'organization creation in hubee on approve'

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

      describe 'when scope already exists in HubEE' do
        let(:existing_subscription_id) { 'existing-sub-id-123' }
        let(:existing_subscriptions) do
          [
            { 'id' => existing_subscription_id, 'processCode' => 'EtatCivil', 'datapassId' => authorization_request.id },
            { 'id' => 'other-sub-id', 'processCode' => 'depotDossierPACS', 'datapassId' => authorization_request.id }
          ]
        end

        before do
          allow(hubee_api_client).to receive(:create_subscription).and_raise(HubEEAPIClient::AlreadyExistsError)
          allow(hubee_api_client).to receive(:find_subscriptions).and_return(existing_subscriptions.map(&:with_indifferent_access))
          allow(Sentry).to receive(:capture_message)
        end

        it 'does not raise an error' do
          expect { hubee_dila_bridge }.not_to raise_error
        end

        it 'fetches existing subscriptions from HubEE' do
          hubee_dila_bridge

          expect(hubee_api_client).to have_received(:find_subscriptions).with(datapassId: authorization_request.id).twice
        end

        it 'sends a warning to Sentry for each existing subscription' do
          hubee_dila_bridge

          %w[etat_civil depot_dossier_pacs].each do |scope|
            expect(Sentry).to have_received(:capture_message).with(
              "HubEE subscription already exists for authorization_request ##{authorization_request.id} (scope: #{scope})",
              level: :warning,
              extra: hash_including(scope:)
            )
          end
        end

        it 'stores the existing HubEE subscription IDs' do
          hubee_dila_bridge

          stored = JSON.parse(authorization_request.reload.external_provider_id)
          expect(stored['etat_civil']).to eq(existing_subscription_id)
          expect(stored['depot_dossier_pacs']).to eq('other-sub-id')
        end
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
