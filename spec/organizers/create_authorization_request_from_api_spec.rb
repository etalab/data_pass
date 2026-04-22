RSpec.describe CreateAuthorizationRequestFromAPI, type: :organizer do
  describe '.call' do
    subject(:result) do
      described_class.call(
        form_uid: 'api-entreprise',
        authorized_types: %w[AuthorizationRequest::APIEntreprise],
        authorization_request_params: ActionController::Parameters.new(data),
        applicant_params:,
        siret: '13002526500013',
        user: oauth_user
      )
    end

    let!(:oauth_user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
    let(:applicant_params) do
      { email: 'applicant@example.com', given_name: 'Jean', family_name: 'Dupont' }
    end
    let(:data) { { intitule: 'Mon projet' } }

    context 'when everything succeeds' do
      it { is_expected.to be_a_success }

      it 'creates the authorization request' do
        expect { result }.to change(AuthorizationRequest, :count).by(1)
      end

      it 'enqueues the INSEE refresh job' do
        expect { result }.to have_enqueued_job(UpdateOrganizationINSEEPayloadJob)
      end
    end

    context 'with a FranceConnect-certified api-particulier form' do
      subject(:result) do
        described_class.call(
          form_uid: 'api-particulier-aiga',
          authorized_types: %w[AuthorizationRequest::APIParticulier],
          authorization_request_params: ActionController::Parameters.new(
            intitule: 'Projet FC',
            modalities: %w[france_connect]
          ),
          applicant_params:,
          siret: '13002526500013',
          user: oauth_user
        )
      end

      let!(:oauth_user) { create(:user, :developer, authorization_request_types: %w[api_particulier]) }

      it 'runs AssignFranceConnectDefaults to set FC default attributes' do
        result

        expect(result.authorization_request.fc_eidas).to eq(FranceConnectDefaultData::FC_EIDAS)
      end

      it 'adds FranceConnect scopes to the request' do
        result

        fc_scopes = FranceConnectDefaultData.scope_values

        expect(result.authorization_request.scopes).to include(*fc_scopes)
      end
    end

    context 'when a later interactor fails after side effects' do
      before do
        allow(CreateAuthorizationRequestEventModel).to receive(:call!).and_wrap_original do |_m, context|
          context.fail!(error: { key: :authorization_request_invalid, errors: ['boom'], format: nil })
        end
      end

      it 'fails' do
        expect(result).to be_a_failure
      end

      it 'rolls back the applicant' do
        expect { result }.not_to change(User, :count)
      end

      it 'rolls back the organization' do
        expect { result }.not_to change(Organization, :count)
      end

      it 'rolls back the organization link' do
        expect { result }.not_to change(OrganizationsUser, :count)
      end

      it 'rolls back the authorization request' do
        expect { result }.not_to change(AuthorizationRequest, :count)
      end

      it 'does not enqueue the INSEE refresh job' do
        expect { result }.not_to have_enqueued_job(UpdateOrganizationINSEEPayloadJob)
      end
    end

    context 'when save fails and applicant was pre-existing' do
      let!(:existing_user) { create(:user, email: 'applicant@example.com', given_name: 'Old', family_name: 'Name') }

      before do
        allow(SaveAuthorizationRequest).to receive(:call!).and_wrap_original do |_m, context|
          context.fail!(error: { key: :authorization_request_invalid, errors: ['boom'], format: nil })
        end
      end

      it 'preserves the existing applicant' do
        expect { result }.not_to change(User, :count)
      end

      it 'does not destroy the existing applicant' do
        result

        expect(User.find_by(email: 'applicant@example.com')).to eq(existing_user)
      end
    end

    context 'when save fails and organization was pre-existing' do
      let!(:existing_org) { create(:organization, legal_entity_id: '13002526500013', legal_entity_registry: 'insee_sirene') }

      before do
        allow(SaveAuthorizationRequest).to receive(:call!).and_wrap_original do |_m, context|
          context.fail!(error: { key: :authorization_request_invalid, errors: ['boom'], format: nil })
        end
      end

      it 'preserves the existing organization' do
        expect { result }.not_to change(Organization, :count)
      end

      it 'does not destroy the existing organization' do
        result

        expect(Organization.find_by(legal_entity_id: '13002526500013')).to eq(existing_org)
      end
    end
  end
end
