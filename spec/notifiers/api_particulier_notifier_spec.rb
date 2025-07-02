RSpec.describe APIParticulierNotifier, type: :notifier do
  describe '#approve' do
    subject(:approve) { notifier.approve({}) }

    let(:notifier) { described_class.new(authorization_request) }

    context 'when authorization request is not linked to a FranceConnect habilitation' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated) }

      it 'does not send an email to FranceConnect' do
        expect { approve }.not_to have_enqueued_mail(FranceConnectMailer, :new_scopes)
      end
    end

    context 'when authorization request has a FranceConnect habilitation' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated, :with_france_connect, modalities: %w[france_connect]) }

      it 'sends an email to FranceConnect' do
        expect { approve }.to have_enqueued_mail(FranceConnectMailer, :new_scopes)
      end
    end

    context 'when authorization request has a formulaire_qf modality' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated, modalities: %w[formulaire_qf]) }

      it 'notifies the formulaire_qf webhook' do
        expect(DeliverAuthorizationRequestWebhookJob).to receive(:new).with(
          'api_particulier',
          a_string_matching(/approve/),
          authorization_request.id,
        ).and_call_original

        expect(DeliverAuthorizationRequestWebhookJob).to receive(:new).with(
          'formulaire_qf',
          a_string_matching(/approve/),
          authorization_request.id,
        ).and_call_original

        approve
      end
    end

    context 'when authorization request does not have a formulaire_qf modality' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated, modalities: []) }

      it 'does not notify the formulaire_qf webhook' do
        expect(DeliverAuthorizationRequestWebhookJob).not_to receive(:new)
      end
    end
  end
end
