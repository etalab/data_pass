require 'rails_helper'

RSpec.describe AuthorizationRequestMailer do
  describe '#validated' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).validated
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match('a été validée')
    end
  end

  describe '#refused' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).refused
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

  describe '#changes_requested' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).changes_requested
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
end
