shared_examples 'creates an event' do |options|
  it 'creates an authorization request event' do
    expect { subject }.to change(AuthorizationRequestEvent, :count).by(1)

    authorization_request_event = AuthorizationRequestEvent.last

    expect(authorization_request_event.name).to eq(options[:event_name].to_s)

    expect(authorization_request_event.entity_type).to eq(options[:entity_type].to_s.classify) if options[:entity_type]
  end
end
