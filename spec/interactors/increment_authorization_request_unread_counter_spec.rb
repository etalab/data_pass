RSpec.describe IncrementAuthorizationRequestUnreadCounter do
  subject(:increment_counter) { described_class.call(authorization_request:, unread_counter_target: :applicant) }

  let(:authorization_request) { create(:authorization_request) }
  let(:counter) { authorization_request.redis_unread_messages_from_applicant }

  before { counter.reset }

  it 'increments the unread counter of the target' do
    expect { increment_counter }.to change(counter, :value).by(1)
  end

  context 'when called inside a transaction' do
    it 'increments the counter once the transaction commits' do
      expect {
        ActiveRecord::Base.transaction(requires_new: true) do
          expect { increment_counter }.not_to change(counter, :value)
        end
      }.to change(counter, :value).by(1)
    end

    it 'leaves the counter untouched when the transaction rolls back' do
      expect {
        ActiveRecord::Base.transaction(requires_new: true) do
          increment_counter

          raise ActiveRecord::Rollback
        end
      }.not_to change(counter, :value)
    end
  end
end
