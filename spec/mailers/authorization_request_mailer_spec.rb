require 'rails_helper'

RSpec.describe AuthorizationRequestMailer do
  def decoded_text_body(mail)
    mail.multipart? ? mail.text_part.body.decoded : mail.body.decoded
  end

  def decoded_html_body(mail)
    mail.html_part&.body&.decoded
  end

  describe 'html rendering' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).approve
    end

    context 'when there is a custom HTML template for the authorization request kind' do
      let(:authorization_request) { create(:authorization_request, :annuaire_des_entreprises, :validated) }

      it 'renders the custom template which is html' do
        html = decoded_html_body(mail)
        expect(html).to match('href')
        expect(html).to match('espace agent')
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
          expect(decoded_text_body(mail)).to match('Portail HubEE')
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
          expect(decoded_text_body(mail)).to match('DGFiP')
        end
      end

      describe 'annuaire des entreprises' do
        let(:authorization_request) { create(:authorization_request, :annuaire_des_entreprises, :validated) }

        it 'renders valid custom template' do
          expect(decoded_text_body(mail)).to match('espace agent')
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
