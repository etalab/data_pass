shared_examples 'creates an event' do |options|
  it 'creates an authorization request event' do
    expect { subject }.to change(AuthorizationRequestEvent, :count).by(1)

    authorization_request_event = AuthorizationRequestEvent.last

    expect(authorization_request_event.name).to eq(options[:event_name].to_s)

    expect(authorization_request_event.entity_type).to eq(options[:entity_type].to_s.classify) if options[:entity_type]
    expect(authorization_request_event.authorization_request).to be_present unless authorization_request_event.name == 'bulk_update'
  end
end

shared_examples 'delivers a webhook' do |options|
  context 'when authorization request has webhooks activated for all events' do
    let(:authorization_request_kind) { :api_entreprise }

    it 'delivers a webhook for this event' do
      expect { subject }.to have_enqueued_job(DeliverAuthorizationRequestWebhookJob).with(
        authorization_request.definition.id,
        a_string_matching("\"event\":\"#{options[:event_name]}\""),
        authorization_request.id,
      ), "Expected to have enqueued a webhook delivery job with the event name #{options[:event_name]}"
    end
  end
end
