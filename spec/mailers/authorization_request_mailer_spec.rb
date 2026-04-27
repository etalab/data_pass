require 'rails_helper'

RSpec.describe AuthorizationRequestMailer do
  describe 'html rendering' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).approve
    end

    context 'when there is a custom HTML template for the authorization request kind' do
      let(:authorization_request) { create(:authorization_request, :annuaire_des_entreprises, :validated) }

      it 'renders the custom template which is html' do
        expect(mail.body.encoded).to match('href')
        expect(mail.body.encoded).to match('espace agent')
      end
    end

    context 'when there is no custom HTML template for the kind' do
      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }

      it 'renders the generic HTML template' do
        html = decoded_html_body(mail)
        expect(html).to be_present
        expect(html).to match('validée')
        expect(html).to match('consulter')
      end
    end
  end

  describe '#approve' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).approve
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template' do
      expect(decoded_text_body(mail)).to match('a été validée')
    end

    describe 'custom emails' do
      describe 'HubEE CertDC' do
        let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }

        it 'renders valid custom template' do
          expect(mail.body.encoded).to match('Portail HubEE')
        end
      end

      describe 'HubEE DILA' do
        let(:authorization_request) { create(:authorization_request, :hubee_dila, :validated) }

        it 'renders valid custom template' do
          expect(decoded_text_body(mail)).to match('Portail HubEE')
        end
      end

      describe 'API R2P sandbox' do
        let(:authorization_request) { create(:authorization_request, :api_r2p_sandbox, :validated) }

        it 'renders valid custom template' do
          expect(mail.body.encoded).to match('DGFiP')
        end
      end

      describe 'annuaire des entreprises' do
        let(:authorization_request) { create(:authorization_request, :annuaire_des_entreprises, :validated) }

        it 'renders valid custom template' do
          expect(mail.body.encoded).to match('espace agent')
        end
      end

      describe 'FranceConnect' do
        let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }

        it 'renders valid custom template for new habilitation' do
          text = decoded_text_body(mail)
          expect(text).to match('Votre habilitation a été validée')
          expect(text).to match('demander la création de votre fournisseur de service')
          expect(text).to match('espace.partenaires.franceconnect.gouv.fr')
        end
      end
    end
  end

  describe '#refuse' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).refuse
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :refused) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template, with denial reason' do
      text = decoded_text_body(mail)
      expect(text).to match('a été refusée')
      expect(text).to match(authorization_request.denial.reason)
    end
  end

  describe '#revoke' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).revoke
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :revoked) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template' do
      expect(decoded_text_body(mail)).to match('a été révoquée')
    end

    it 'renders HTML part' do
      html = decoded_html_body(mail)
      expect(html).to be_present
      expect(html).to match('révoquée')
    end
  end

  describe '#changes_requested' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).request_changes
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :changes_requested) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template, with modification request reason' do
      text = decoded_text_body(mail)
      expect(text).to match('des modifications')
      expect(text).to match(authorization_request.modification_request.reason)
    end
  end

  describe '#reopening_approve' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).reopening_approve
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template' do
      text = decoded_text_body(mail)
      expect(text).to match('a été validée')
      expect(text).to match('réouverture')
    end

    describe 'FranceConnect' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }

      it 'renders valid custom template for reopening' do
        text = decoded_text_body(mail)
        expect(text).to match('La mise à jour de votre habilitation a été validée')
        expect(text).to match('demande-modification-fs-fc')
        expect(text).to match('demarches-simplifiees.fr')
      end
    end
  end

  describe '#reopening_refuse' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).reopening_refuse
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :refused) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template, with denial reason' do
      text = decoded_text_body(mail)
      expect(text).to match('a été refusée')
      expect(text).to match('réouverture')
      expect(text).to match(authorization_request.denial.reason)
    end
  end

  describe '#submit' do
    subject(:mail) { described_class.with(authorization_request:).submit }

    context 'when messaging is enabled' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, last_submitted_at: 1.day.ago) }

      it 'sends the email to the applicant' do
        expect(mail.to).to eq([authorization_request.applicant.email])
      end

      it 'renders valid template with legal content' do
        text = decoded_text_body(mail)
        expect(text).to match('accusons réception')
        expect(text).to match(authorization_request.id.to_s)
        expect(text).to match('CRPA')
      end

      it 'includes the messages url' do
        expect(decoded_text_body(mail)).to match('messagerie')
      end
    end

    context 'when messaging is disabled' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_sandbox, :submitted, last_submitted_at: 1.day.ago) }

      it 'includes the support email' do
        expect(decoded_text_body(mail)).to match(authorization_request.definition.support_email)
      end

      it 'does not include the messages url' do
        expect(decoded_text_body(mail)).not_to match('messagerie')
      end
    end
  end

  describe '#reopening_submit' do
    subject(:mail) { described_class.with(authorization_request:).reopening_submit }

    context 'when messaging is enabled' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :reopened_and_submitted) }

      it 'sends the email to the applicant' do
        expect(mail.to).to eq([authorization_request.applicant.email])
      end

      it 'renders valid template with legal content' do
        text = decoded_text_body(mail)
        expect(text).to match('accusons réception')
        expect(text).to match(authorization_request.id.to_s)
        expect(text).to match('CRPA')
      end

      it 'includes the messages url' do
        expect(decoded_text_body(mail)).to match('messagerie')
      end
    end

    context 'when messaging is disabled' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_sandbox, :reopened_and_submitted) }

      it 'includes the support email' do
        expect(decoded_text_body(mail)).to match(authorization_request.definition.support_email)
      end

      it 'does not include the messages url' do
        expect(decoded_text_body(mail)).not_to match('messagerie')
      end
    end
  end

  describe '#reopening_request_changes' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).reopening_request_changes
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :changes_requested) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template, with modification request reason' do
      text = decoded_text_body(mail)
      expect(text).to match('réouverture')
      expect(text).to match('des modifications')
      expect(text).to match(authorization_request.modification_request.reason)
    end
  end
end
