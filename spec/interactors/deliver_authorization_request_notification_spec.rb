RSpec.describe DeliverAuthorizationRequestNotification, type: :interactor do
  subject(:interactor) { described_class.call(context_params) }

  let(:authorization_request) { create(:authorization_request, :api_entreprise_mgdis, :submitted) }
  let(:context_params) { { authorization_request:, state_machine_event: :submit } }
  let!(:webhook) do
    create(:webhook, authorization_definition_id: 'api_entreprise', events: %w[submit], enabled: true, validated: true)
  end

  it 'tells the webhook that the event comes from the web by default' do
    expect { interactor }.to have_enqueued_job(DeliverAuthorizationRequestWebhookJob).with(
      webhook.id, authorization_request.id, 'submit', hash_including(source: 'web')
    )
  end

  context 'when the event comes from the API' do
    let(:context_params) { super().merge(event_source: 'api') }

    it 'tells the webhook that the event comes from the API' do
      expect { interactor }.to have_enqueued_job(DeliverAuthorizationRequestWebhookJob).with(
        webhook.id, authorization_request.id, 'submit', hash_including(source: 'api')
      )
    end
  end

  context 'when the event is an API history event' do
    let(:context_params) { { authorization_request:, event_name: 'update_by_api', event_source: 'api' } }
    let!(:webhook) do
      create(:webhook, authorization_definition_id: 'api_entreprise', events: %w[update], enabled: true, validated: true)
    end

    it 'delivers it under the public event name' do
      expect { interactor }.to have_enqueued_job(DeliverAuthorizationRequestWebhookJob).with(
        webhook.id, authorization_request.id, 'update', hash_including(event: 'update')
      )
    end
  end

  context 'when several webhooks listen to the event' do
    before do
      create(:webhook, authorization_definition_id: 'api_entreprise', events: %w[submit], enabled: true, validated: true)
    end

    it 'serializes the authorization request once' do
      allow(WebhookSerializer).to receive(:new).and_call_original

      interactor

      expect(WebhookSerializer).to have_received(:new).once
    end
  end
end
