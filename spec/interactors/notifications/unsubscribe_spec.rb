RSpec.describe Notifications::Unsubscribe do
  subject(:organizer) { described_class.call(user:, definition_id:, kind:) }

  let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise api_particulier]) }
  let(:definition_id) { 'api_entreprise' }
  let(:kind) { 'submit' }

  describe 'when kind is submit' do
    it 'disables the submit notification for the given API' do
      expect { organizer }.to change {
        user.reload.instruction_submit_notifications_for_api_entreprise
      }.to(false)
    end

    it 'does not affect the messages notification for the same API' do
      organizer
      expect(user.reload.instruction_messages_notifications_for_api_entreprise).to be_truthy
    end

    it 'does not affect the submit notification for another API' do
      organizer
      expect(user.reload.instruction_submit_notifications_for_api_particulier).to be_truthy
    end
  end

  describe 'when kind is messages' do
    let(:kind) { 'messages' }

    it 'disables the messages notification for the given API' do
      expect { organizer }.to change {
        user.reload.instruction_messages_notifications_for_api_entreprise
      }.to(false)
    end

    it 'does not affect the submit notification for the same API' do
      organizer
      expect(user.reload.instruction_submit_notifications_for_api_entreprise).to be_truthy
    end
  end

  describe 'when the user is already unsubscribed' do
    before { user.update!('instruction_submit_notifications_for_api_entreprise' => '0') }

    it 'flags already_unsubscribed' do
      expect(organizer.already_unsubscribed).to be(true)
    end
  end
end
