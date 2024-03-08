RSpec.describe SendMessageToApplicant do
  subject(:send_message_to_applicant) { described_class.call(authorization_request:, user:, message_params:) }

  let(:message_params) { attributes_for(:message) }
  let(:user) { create(:user, :instructor) }
  let(:authorization_request) { create(:authorization_request) }

  context 'with valid attributes' do
    it { is_expected.to be_success }

    it 'creates a message for authorization request' do
      expect { send_message_to_applicant }.to change { authorization_request.messages.count }.by(1)
    end

    it 'creates message from user, with sent at now' do
      send_message_to_applicant

      message = authorization_request.messages.last

      expect(message.from).to eq(user)
      expect(message.sent_at).to be_within(1.second).of(Time.current)
    end

    it 'delivers an email to applicant' do
      expect { send_message_to_applicant }.to have_enqueued_mail(MessageMailer, :to_applicant)
    end

    context 'when it is a reopening' do
      let(:authorization_request) { create(:authorization_request, :reopened) }

      it 'delivers an email specific to reopening to applicant' do
        expect { send_message_to_applicant }.to have_enqueued_mail(MessageMailer, :reopening_to_applicant)
      end
    end

    it 'increments the unread messages count for applicant, not for instructors' do
      expect { send_message_to_applicant }.to change(authorization_request, :unread_messages_from_applicant_count).by(1)

      expect(authorization_request.unread_messages_from_instructors_count).to eq(0)
    end

    include_examples 'creates an event', event_name: :instructor_message, entity_type: :message
  end
end
