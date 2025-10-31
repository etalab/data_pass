RSpec.describe WebhookMailer do
  describe '.fail' do
    subject(:mail) do
      described_class.with(
        webhook:
      ).fail
    end

    let(:webhook) { create(:webhook, authorization_definition_id: 'api_entreprise', url: webhook_url) }
    let!(:api_entreprise_developer) { create(:user, roles: ['api_entreprise:developer']) }
    let!(:foreign_developer) { create(:user, roles: ['api_particulier:developer']) }
    let(:webhook_url) { 'https://service.api.gouv.fr/webhook' }

    it 'sends email to definition developers, from datapass@api.gouv.fr' do
      expect(mail.to).to include(api_entreprise_developer.email)
      expect(mail.to).not_to include(foreign_developer.email)

      expect(mail.from).to eq(['datapass@api.gouv.fr'])
    end

    it 'renders relevant information in body and subject' do
      expect(mail.subject).to include('API Entreprise')
      expect(mail.body.encoded).to include(webhook_url)
      expect(mail.body.encoded).to include("/developpeurs/webhooks/#{webhook.id}/appels")
    end
  end
end
