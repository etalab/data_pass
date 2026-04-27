require 'rails_helper'

RSpec.describe DGFIP::APIMMailer do
  describe '#approve' do
    let(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :validated) }
    let(:authorization) { create(:authorization, request: authorization_request, data: authorization_request.data) }

    context 'when it is a new request' do
      let(:mail) do
        described_class.with(
          authorization:,
          reopening: false
        ).approve
      end

      it 'sends to the DGFiP APIM emails from test credentials' do
        expect(mail.to).to eq ['test1@dgfip.finances.gouv.fr', 'test2@dgfip.finances.gouv.fr', 'test3@dgfip.finances.gouv.fr', 'test4@dgfip.finances.gouv.fr']
      end

      it 'has the correct subject for new request' do
        expect(mail.subject).to eq(
          I18n.t('dgfip_apim_mailer.approve.subject', authorization_request_id: authorization_request.formatted_id)
        )
      end

      it 'includes the authorization_request\'s formatted_id in the body' do
        expect(mail.body.encoded).to include(authorization_request.formatted_id)
      end

      it 'includes the authorization\'s formatted id in the body' do
        expect(mail.body.encoded).to include(authorization.formatted_id)
      end

      it 'includes BAS for sandbox stage' do
        expect(mail.body.encoded).to include('BAS')
      end

      it 'does not include mise à jour in the body' do
        expect(mail.body.encoded).not_to include('mise à jour')
      end
    end

    context 'when it is a reopening (mise à jour)' do
      let(:mail) do
        described_class.with(
          authorization:,
          reopening: true
        ).approve
      end

      it 'has the correct subject for reopening' do
        expect(mail.subject).to eq(
          I18n.t('dgfip_apim_mailer.approve.reopening_subject', authorization_request_id: authorization_request.formatted_id)
        )
      end

      it 'includes mise à jour in the body' do
        expect(mail.body.encoded).to include('mise à jour')
      end
    end

    context 'when it is a production request' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :validated) }

      let(:mail) do
        described_class.with(
          authorization:,
          reopening: false
        ).approve
      end

      it 'includes PROD for production stage' do
        expect(mail.body.encoded).to include('PROD')
      end
    end

    context 'when the API has no specific emails configured' do
      let(:authorization_request) { create(:authorization_request, :api_hermes_sandbox, :validated) }

      let(:mail) do
        described_class.with(
          authorization:,
          reopening: false
        ).approve
      end

      it 'sends only to the base DGFiP APIM emails' do
        expect(mail.to).to eq ['test1@dgfip.finances.gouv.fr', 'test2@dgfip.finances.gouv.fr']
      end
    end
  end
end
