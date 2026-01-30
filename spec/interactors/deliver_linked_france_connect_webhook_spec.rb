require 'rails_helper'

RSpec.describe DeliverLinkedFranceConnectWebhook do
  describe '#call' do
    subject(:interactor) { described_class.call(context_params) }

    let(:authorization_request) { create(:authorization_request, :api_particulier, :with_france_connect_embedded_fields, fill_all_attributes: true) }
    let(:authorization) { create(:authorization, request: authorization_request) }
    let(:linked_france_connect_authorization) { create(:authorization, request: authorization_request, parent_authorization: authorization, authorization_request_class: 'AuthorizationRequest::FranceConnect') }
    let(:state_machine_event) { :approve }

    let(:context_params) do
      {
        authorization_request:,
        authorization:,
        linked_france_connect_authorization:,
        state_machine_event:
      }
    end

    context 'when there is a linked FC authorization and an active FC webhook' do
      let!(:webhook) do
        create(:webhook, authorization_definition_id: 'france_connect', events: ['approve'], enabled: true, validated: true)
      end

      it 'enqueues a webhook delivery job' do
        expect { interactor }.to have_enqueued_job(DeliverAuthorizationRequestWebhookJob).with(
          webhook.id,
          authorization_request.id,
          'approve',
          hash_including(event: 'approve')
        )
      end
    end

    context 'when there is no linked FC authorization' do
      let(:linked_france_connect_authorization) { nil }

      let!(:webhook) do
        create(:webhook, authorization_definition_id: 'france_connect', events: ['approve'], enabled: true, validated: true)
      end

      it 'does not enqueue any webhook delivery job' do
        expect { interactor }.not_to have_enqueued_job(DeliverAuthorizationRequestWebhookJob)
      end
    end

    context 'when there is no active FC webhook' do
      it 'does not enqueue any webhook delivery job' do
        expect { interactor }.not_to have_enqueued_job(DeliverAuthorizationRequestWebhookJob)
      end
    end

    context 'when the webhook does not listen to the event' do
      let!(:webhook) do
        create(:webhook, authorization_definition_id: 'france_connect', events: ['submit'], enabled: true, validated: true)
      end

      it 'does not enqueue any webhook delivery job' do
        expect { interactor }.not_to have_enqueued_job(DeliverAuthorizationRequestWebhookJob)
      end
    end
  end
end
