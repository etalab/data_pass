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
  end
end
