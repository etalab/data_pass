RSpec.describe BaseNotifier, type: :notifier do
  subject(:notifier) { described_class.new(authorization_request) }

  let(:authorization_request) { create(:authorization_request, :api_entreprise) }

  describe '#approve with reopening flag' do
    it 'enqueues the reopening_approve email via AuthorizationRequestMailer' do
      expect {
        notifier.approve({ within_reopening: true })
      }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_approve)
    end
  end

  describe '#refuse with reopening flag' do
    it 'enqueues the reopening_refuse email via AuthorizationRequestMailer' do
      expect {
        notifier.refuse({ within_reopening: true })
      }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_refuse)
    end
  end

  describe '#request_changes with reopening flag' do
    it 'enqueues the reopening_request_changes email via AuthorizationRequestMailer' do
      expect {
        notifier.request_changes({ within_reopening: true })
      }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_request_changes)
    end
  end

  describe '#approve without reopening flag' do
    it 'enqueues the approve email' do
      expect {
        notifier.approve({})
      }.to have_enqueued_mail(AuthorizationRequestMailer, :approve)
    end
  end

  describe '#submit to Instruction::AuthorizationRequestMailer' do
    it 'enqueues the submit email to instruction mailer without reopening' do
      expect {
        notifier.submit({})
      }.to have_enqueued_mail(Instruction::AuthorizationRequestMailer, :submit)
    end

    it 'enqueues the reopening_submit email to instruction mailer when reopening' do
      expect {
        notifier.submit({ within_reopening: true })
      }.to have_enqueued_mail(Instruction::AuthorizationRequestMailer, :reopening_submit)
    end
  end

  describe '#submit email in case of changes requested' do
    let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: ['api_entreprise'], instruction_submit_notifications_for_api_entreprise: true) }

    before do
      ActiveJob::Base.queue_adapter = :inline
    end

    after do
      ActiveJob::Base.queue_adapter = :test
    end

    context 'when there is a changes requested' do
      before { create(:instructor_modification_request, authorization_request:) }

      it 'delivers an email that contains the modification sentence' do
        expect {
          notifier.submit({})
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        last_mail = ActionMailer::Base.deliveries.last
        expect(last_mail.body.encoded).to include('Cette demande fait suite à une demande de modification.')
      end
    end

    context 'when there is no changes requested' do
      it 'delivers an email that does not contain the modification sentence' do
        expect {
          notifier.submit({})
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        last_mail = ActionMailer::Base.deliveries.last
        expect(last_mail.body.encoded).not_to include('Cette demande fait suite à une demande de modification.')
      end
    end
  end
end
