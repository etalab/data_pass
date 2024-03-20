RSpec.describe WebhookMailer do
  describe '.fail' do
    subject(:mail) do
      described_class.with(
        target_api:,
        payload:,
        webhook_response_status:,
        webhook_response_body:
      ).fail
    end

    let(:target_api) { 'api_entreprise' }
    let!(:api_entreprise_instructor) { create(:user, roles: ['api_entreprise:instructor']) }
    let!(:foreign_instructor) { create(:user, roles: ['api_particulier:instructor']) }
    let(:payload) { { lol: 'oki' } }
    let(:webhook_response_body) { 'PANIK' }
    let(:webhook_response_status) { 500 }

    let(:webhook_url) { 'https://service.api.gouv.fr/webhook' }

    before do
      ENV["#{target_api.upcase}_WEBHOOK_URL"] = webhook_url
    end

    after do
      ENV["#{target_api.upcase}_WEBHOOK_URL"] = nil
    end

    it 'sends email to target api instructors, from datapass@api.gouv.fr with equipe-datapass@api.gouv.fr in cc' do
      expect(mail.to).to include(api_entreprise_instructor.email)
      expect(mail.to).not_to include(foreign_instructor.email)

      expect(mail.from).to eq(['datapass@api.gouv.fr'])
    end

    it 'renders relevant information in body and subject' do
      expect(mail.subject).to include('API Entreprise')
      expect(mail.body.encoded).to include(webhook_url)
      expect(mail.body.encoded).to include('"lol": "oki"')
      expect(mail.body.encoded).to include(webhook_response_status.to_s)
      expect(mail.body.encoded).to include(webhook_response_body)
    end
  end
end
