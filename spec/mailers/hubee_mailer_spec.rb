require 'rails_helper'

RSpec.describe HubEEMailer do
  describe '#administrateur_metier' do
    context 'with cert_dc' do
      let(:mail) { described_class.with(authorization_request:).administrateur_metier(:cert_dc) }

      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }

      it 'renders the headers' do
        expect(mail.to).to eq([authorization_request.administrateur_metier_email])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to match('HubEE')
      end
    end

    context 'with dila' do
      let(:mail) { described_class.with(authorization_request:).administrateur_metier(:dila) }

      let(:authorization_request) { create(:authorization_request, :hubee_dila, :validated) }

      it 'renders the headers' do
        expect(mail.to).to eq([authorization_request.administrateur_metier_email])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to match('HubEE')
      end
    end
  end

  describe '#formulaire_qf_validation' do
    subject(:mail) { described_class.with(authorization_request:).formulaire_qf_validation }

    let(:recipients) { %w[support-hubee@yopmail.com] }
    let(:authorization_request) { create(:authorization_request, :formulaire_qf, :validated) }

    before do
      allow(Setting).to receive(:fetch).and_call_original
      allow(Setting).to receive(:fetch).with(:hubee_formulaire_qf_notification_emails).and_return(recipients)
    end

    it 'is sent to the HubEE support recipients from credentials' do
      expect(mail.to).to eq(recipients)
    end

    it 'renders a subject with the request id and the organization name' do
      expect(mail.subject).to include(authorization_request.formatted_id, authorization_request.organization.name)
    end

    it 'renders the request name, form name and organization siret' do
      expect(mail.body.encoded).to include(authorization_request.name, authorization_request.form.name, authorization_request.organization.siret)
    end

    context 'when the request comes from a formulaire QF without editor' do
      it 'does not mention any editor' do
        expect(mail.body.encoded).not_to include('Éditeur')
      end
    end

    context 'when the request comes from an editor form' do
      let(:authorization_request) { create(:authorization_request, :api_particulier_3d_ouest, :validated, modalities: %w[params formulaire_qf]) }

      it 'renders the editor name' do
        expect(mail.body.encoded).to include('Éditeur : 3D Ouest')
      end
    end

    context 'when no recipient is configured' do
      let(:recipients) { [] }

      before { allow(Sentry).to receive(:capture_message) }

      it 'does not send any email' do
        expect(mail.message).to be_a(ActionMailer::Base::NullMail)
      end

      it 'does not report anything outside production' do
        mail.message

        expect(Sentry).not_to have_received(:capture_message)
      end

      context 'when the application runs in production' do
        before { allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new('production')) }

        it 'reports the missing configuration to Sentry' do
          mail.message

          expect(Sentry).to have_received(:capture_message).with(/no recipient configured/, level: :warning)
        end
      end
    end
  end
end
