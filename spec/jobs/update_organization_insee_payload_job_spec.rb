RSpec.describe UpdateOrganizationINSEEPayloadJob do
  subject(:update_organization_insee_payload_job) { described_class.perform_now(organization_id) }

  context 'with invalid organization' do
    let(:organization_id) { 0 }

    it 'does not call the API' do
      expect(INSEESireneAPIClient).not_to receive(:new)

      update_organization_insee_payload_job
    end
  end

  context 'with foreign organization' do
    let(:organization_id) { create(:organization, :foreign).id }

    it 'does not call the API' do
      expect(INSEESireneAPIClient).not_to receive(:new)

      update_organization_insee_payload_job
    end
  end

  context 'with valid organization' do
    let(:organization_id) { organization.id }

    let(:insee_sirene_api_client) { instance_double(INSEESireneAPIClient, etablissement: insee_sirene_api_etablissement_payload) }
    let(:insee_sirene_api_etablissement_payload) { insee_sirene_api_etablissement_valid_payload(siret: organization.siret) }

    before do
      allow(INSEESireneAPIClient).to receive(:new).and_return(insee_sirene_api_client)
    end

    context 'when organization has been recently updated for his INSEE payload' do
      let(:organization) { create(:organization, last_insee_payload_updated_at: 1.hour.ago) }

      it 'does not call the API' do
        expect(insee_sirene_api_client).not_to receive(:etablissement)

        update_organization_insee_payload_job
      end
    end

    context 'when organization has not been recently updated for his INSEE payload' do
      let(:organization) { create(:organization, last_insee_payload_updated_at: 42.days.ago) }

      it 'calls the API' do
        expect(insee_sirene_api_client).to receive(:etablissement).with(siret: organization.siret)

        update_organization_insee_payload_job
      end

      it 'updates the organization with the payload' do
        update_organization_insee_payload_job

        expect(organization.reload.insee_payload).to eq(insee_sirene_api_etablissement_payload)
      end

      it 'updates the organization last INSEE payload updated at with the current time' do
        update_organization_insee_payload_job

        expect(organization.reload.last_insee_payload_updated_at).to be_within(1.second).of(Time.current)
      end
    end

    context 'when API returns a not found error' do
      let(:organization) { create(:organization, last_insee_payload_updated_at: 42.days.ago) }

      before do
        allow(insee_sirene_api_client).to receive(:etablissement).and_raise(INSEESireneAPIClient::EntityNotFoundError)
        allow(Sentry).to receive(:capture_exception)
      end

      it 'does not raise' do
        expect { update_organization_insee_payload_job }.not_to raise_error
      end

      it 'reports to Sentry as a warning' do
        update_organization_insee_payload_job

        expect(Sentry).to have_received(:capture_exception).with(
          an_instance_of(INSEESireneAPIClient::EntityNotFoundError),
          level: :warning,
        )
      end
    end

    context 'when INSEE rejects the credentials' do
      let(:organization) { create(:organization, last_insee_payload_updated_at: 42.days.ago) }
      let(:other_organization) { create(:organization, last_insee_payload_updated_at: 42.days.ago) }

      before do
        allow(insee_sirene_api_client).to receive(:etablissement).and_raise(Faraday::UnauthorizedError, 'the server responded with status 401')
        allow(Sentry).to receive(:capture_exception)
      end

      after { described_class.insee_calls_pause.remove }

      it 'does not retry the job' do
        expect { update_organization_insee_payload_job }.not_to have_enqueued_job(described_class)
      end

      it 'reports to Sentry' do
        update_organization_insee_payload_job

        expect(Sentry).to have_received(:capture_exception).with(an_instance_of(Faraday::UnauthorizedError))
      end

      it 'stops calling INSEE for the other organizations' do
        update_organization_insee_payload_job
        described_class.perform_now(other_organization.id)

        expect(insee_sirene_api_client).to have_received(:etablissement).once
      end

      it 'stops calling INSEE long enough to stay under the account lockout threshold' do
        update_organization_insee_payload_job

        pause_ttl = Kredis.configured_for(:shared).ttl(described_class.insee_calls_pause.key)

        expect(pause_ttl).to be_within(1.minute).of(described_class::INSEE_CALLS_PAUSE_DURATION)
      end
    end

    context 'when INSEE calls are paused' do
      let(:organization) { create(:organization, last_insee_payload_updated_at: 42.days.ago) }

      before { described_class.insee_calls_pause.mark(expires_in: 1.minute) }

      after { described_class.insee_calls_pause.remove }

      it 'does not call the API' do
        expect(insee_sirene_api_client).not_to receive(:etablissement)

        update_organization_insee_payload_job
      end
    end
  end
end
