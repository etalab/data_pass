RSpec.describe AuthorizationRequestEventsQuery, type: :FEEDME do
  describe '#perform' do
    subject(:events) { described_class.new(authorization_request).perform }

    let(:authorization_request) { create(:authorization_request).reload }

    before do
      AuthorizationRequestEvent::NAMES.each_with_index do |event_name, index|
        create(:authorization_request_event, event_name, authorization_request:, created_at: index.days.ago)
      end
    end

    it 'returns an active record relation' do
      expect(events).to be_a(ActiveRecord::Relation)
    end

    it 'returns all kind of events' do
      expect(events.count).to eq(AuthorizationRequestEvent::NAMES.count)
    end

    it 'returns ordered events by creation date' do
      expect(events.first.name).to eq(AuthorizationRequestEvent::NAMES.first)
    end
  end
end
