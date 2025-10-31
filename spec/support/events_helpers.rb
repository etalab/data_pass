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
  context 'when authorization request has webhooks activated for this event' do
    let!(:webhook) do
      create(:webhook,
        authorization_definition_id: authorization_request.definition.id,
        events: [options[:event_name]],
        validated: true,
        enabled: true)
    end

    it 'delivers a webhook for this event' do
      expect { subject }.to have_enqueued_job(DeliverAuthorizationRequestWebhookJob).with(
        webhook.id,
        authorization_request.id,
        options[:event_name].to_s,
        a_string_including("\"event\":\"#{options[:event_name]}\"")
      )
    end
  end
end
