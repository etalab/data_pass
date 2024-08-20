RSpec.describe AuthorizationRequestEventsQuery, type: :FEEDME do
  describe '#perform' do
    subject(:events) { described_class.new(authorization_request).perform }

    let(:authorization_request) { create(:authorization_request, :api_entreprise).reload }

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

    context 'when there is multiple updates in a row' do
      let!(:newest_update) { create(:authorization_request_event, :update, authorization_request:, created_at: 1.hour.ago) }
      let!(:not_newest_update) { create(:authorization_request_event, :update, authorization_request:, created_at: 2.hours.ago) }
      let!(:update_within_2_other_events) { create(:authorization_request_event, :update, authorization_request:, created_at: 2.days.ago + 1.hour) }

      it 'returns only newest updates in a row' do
        expect(events.count).to eq(AuthorizationRequestEvent::NAMES.count + 2)

        expect(events).to include(newest_update)
        expect(events).to include(update_within_2_other_events)

        expect(events).not_to include(not_newest_update)
      end
    end
  end
end
