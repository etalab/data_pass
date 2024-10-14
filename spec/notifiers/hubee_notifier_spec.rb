RSpec.describe HubEENotifier, type: :notifier do
  it { expect(described_class.superclass).to eq BaseNotifier }

  describe '#approve' do
    subject(:approve) { notifier.approve({}) }

    before(:all) do
      class DummyHubEENotifier < HubEENotifier
        def kind
          :cert_dc
        end
      end
    end

    let(:notifier) { DummyHubEENotifier.new(authorization_request) }
    let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated, applicant:, administrateur_metier_email:) }
    let(:applicant) { create(:user) }

    before do
      ActiveJob::Base.queue_adapter = :inline
    end

    after do
      ActiveJob::Base.queue_adapter = :test
    end

    context 'when applicant email and administrateur_metier_email are different' do
      let(:administrateur_metier_email) { generate(:email) }

      it 'sends 2 emails' do
        expect { approve }.to change { ActionMailer::Base.deliveries.count }.by(2)
      end
    end

    context 'when applicant email and administrateur_metier_email are the same' do
      let(:administrateur_metier_email) { applicant.email }

      it 'sends 1 email' do
        expect { approve }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
