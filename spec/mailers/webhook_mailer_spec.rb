RSpec.describe WebhookMailer do
  describe '.fail' do
    subject(:mail) do
      described_class.with(
        authorization_request_kind:,
        payload:,
        webhook_response_status:,
        webhook_response_body:
      ).fail
    end

    let(:authorization_request_kind) { 'api_entreprise' }
    let!(:api_entreprise_developer) { create(:user, roles: ['api_entreprise:developer']) }
    let!(:foreign_developer) { create(:user, roles: ['api_particulier:developer']) }
    let(:payload) { { lol: 'oki' } }
    let(:webhook_response_body) { 'PANIK' }
    let(:webhook_response_status) { 500 }

    let(:webhook_url) { 'https://service.api.gouv.fr/webhook' }

    before do
      Rails.application.credentials.webhooks.api_entreprise.url = webhook_url
    end

    after do
      Rails.application.credentials.webhooks.api_entreprise.url = nil
    end

    it 'sends email to definition developers, from datapass@api.gouv.fr with equipe-datapass@api.gouv.fr in cc' do
      expect(mail.to).to include(api_entreprise_developer.email)
      expect(mail.to).not_to include(foreign_developer.email)

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
