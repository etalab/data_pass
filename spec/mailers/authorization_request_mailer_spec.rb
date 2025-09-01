require 'rails_helper'

RSpec.describe AuthorizationRequestMailer do
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
      expect(mail.body.encoded).to match('a été validée')
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
          expect(mail.body.encoded).to match('Portail HubEE')
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
      expect(mail.body.encoded).to match('a été refusée')
      expect(mail.body.encoded).to match(authorization_request.denial.reason)
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
      expect(mail.body.encoded).to match('a été révoquée')
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
      expect(mail.body.encoded).to match('des modifications')
      expect(mail.body.encoded).to match(authorization_request.modification_request.reason)
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
      expect(mail.body.encoded).to match('a été validée')
      expect(mail.body.encoded).to match('réouverture')
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
      expect(mail.body.encoded).to match('a été refusée')
      expect(mail.body.encoded).to match('réouverture')
      expect(mail.body.encoded).to match(authorization_request.denial.reason)
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
      expect(mail.body.encoded).to match('réouverture')
      expect(mail.body.encoded).to match('des modifications')
      expect(mail.body.encoded).to match(authorization_request.modification_request.reason)
    end
  end
end
