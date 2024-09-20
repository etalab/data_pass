RSpec.describe AuthorizationRequestEvent do
  it 'has valid factories' do
    AuthorizationRequestEvent::NAMES.each do |name|
      event = build(:authorization_request_event, name)

      expect(event).to be_valid
      expect(event.name).to eq(name)
    end
  end

  describe '#authorization_request' do
    it 'works for each event (except bulk_update)' do
      AuthorizationRequestEvent::NAMES.each do |name|
        next if name == 'bulk_update'

        expect(build(:authorization_request_event, name).authorization_request).to be_a(AuthorizationRequest), "for event #{name}"
      end
    end
  end
end
