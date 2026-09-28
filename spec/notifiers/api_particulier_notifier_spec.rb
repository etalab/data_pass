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

    context 'when the request carries the formulaire QF modality' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated, modalities: %w[params formulaire_qf]) }

      it 'enqueues the HubEE support email' do
        expect { approve }.to have_enqueued_mail(HubEEMailer, :formulaire_qf_validation)
      end
    end

    context 'when the request does not carry the formulaire QF modality' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated, modalities: %w[params]) }

      it 'does not enqueue the HubEE support email' do
        expect { approve }.not_to have_enqueued_mail(HubEEMailer, :formulaire_qf_validation)
      end
    end

    context 'when a reopening brings the request into the formulaire QF scope' do
      subject(:approve) { notifier.approve({ within_reopening: true }) }

      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated, modalities: %w[params]) }

      before do
        authorization_request.modalities = %w[params formulaire_qf]
        authorization_request.save!(validate: false)
        create(:authorization, request: authorization_request, data: authorization_request.data)
      end

      it 'enqueues the HubEE support email' do
        expect { approve }.to have_enqueued_mail(HubEEMailer, :formulaire_qf_validation)
      end
    end

    context 'when authorization request has a FranceConnect habilitation' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated, :with_france_connect, modalities: %w[france_connect]) }

      it 'sends an email to FranceConnect' do
        expect { approve }.to have_enqueued_mail(FranceConnectMailer, :new_scopes)
      end
    end
  end
end
