RSpec.describe ApplicationMailer do
  describe 'links host' do
    subject(:mail) { WebhookMailer.with(webhook:).fail }

    let(:webhook) { create(:webhook, authorization_definition_id: 'api_entreprise') }

    before { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }

    {
      'production' => 'https://datapass.api.gouv.fr',
      'staging' => 'https://staging.datapass.api.gouv.fr',
      'sandbox' => 'https://sandbox.datapass.api.gouv.fr'
    }.each do |environment, expected_host|
      context "when in #{environment}" do
        before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(environment)) }

        it 'builds links on the canonical domain, without provider subdomain' do
          expect(decoded_text_body(mail)).to include("#{expected_host}/developpeurs/webhooks/#{webhook.id}/tentatives")
        end
      end
    end
  end
end
