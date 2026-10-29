RSpec.describe DeliverAuthorizationRequestNotification do
  describe '#call' do
    subject(:deliver_notification) { described_class.call(authorization_request:, state_machine_event: :submit) }

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }
    let!(:webhook) do
      create(:webhook, authorization_definition_id: 'api_entreprise', events: %w[submit], validated: true, enabled: true)
    end

    before do
      authorization_request.update!(metadata: { 'api' => { 'source' => 'api' }, 'datapass' => { 'note' => 'interne' } })
    end

    it 'enqueues a webhook whose payload carries the api metadata only' do
      expect { deliver_notification }.to have_enqueued_job(DeliverAuthorizationRequestWebhookJob).with(
        webhook.id,
        authorization_request.id,
        'submit',
        hash_including(data: hash_including(metadata: { 'source' => 'api' }))
      )
    end
  end
end
