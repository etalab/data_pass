RSpec.describe AuthorizationRequestTransferMailer do
  describe '#success' do
    subject(:mail) do
      described_class.with(
        authorization_request_transfer:,
      ).success
    end

    let(:authorization_request_transfer) { create(:authorization_request_transfer) }

    it 'renders a valid template with both email' do
      expect(mail.body.encoded).to match('été transférée')
      expect(mail.body.encoded).to match(authorization_request_transfer.from.email)
      expect(mail.body.encoded).to match(authorization_request_transfer.to.email)
    end

    it 'sends the email to the old and new applicant' do
      expect(mail.to).to contain_exactly(
        authorization_request_transfer.from.email,
        authorization_request_transfer.to.email,
      )
    end
  end
end
