RSpec.describe SendMessageToInstructors do
  subject(:send_message_to_instructors) { described_class.call(authorization_request:, user:, message_params:) }

  let(:message_params) { attributes_for(:message) }
  let(:user) { create(:user) }
  let(:authorization_request) { create(:authorization_request) }

  context 'with valid attributes' do
    it { is_expected.to be_success }

    it 'creates a message for authorization request' do
      expect { send_message_to_instructors }.to change { authorization_request.messages.count }.by(1)
    end

    it 'creates message from user, with sent at now' do
      send_message_to_instructors

      message = authorization_request.messages.last

      expect(message.from).to eq(user)
      expect(message.sent_at).to be_within(1.second).of(Time.current)
    end

    it 'delivers an email to instructors' do
      expect { send_message_to_instructors }.to have_enqueued_mail(MessageMailer, :to_instructors)
    end

    context 'when it is a reopening' do
      let(:authorization_request) { create(:authorization_request, :reopened) }

      it 'delivers an email specific to reopening to instructors' do
        expect { send_message_to_instructors }.to have_enqueued_mail(MessageMailer, :reopening_to_instructors)
      end
    end

    it 'increments the unread messages count for instructors, not for applicant' do
      expect { send_message_to_instructors }.to change(authorization_request, :unread_messages_from_instructors_count).by(1)

      expect(authorization_request.unread_messages_from_applicant_count).to eq(0)
    end

    it_behaves_like 'creates an event', event_name: :applicant_message, entity_type: :message
  end
end
