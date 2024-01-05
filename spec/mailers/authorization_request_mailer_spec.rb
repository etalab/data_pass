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
end
