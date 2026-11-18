RSpec.describe TransactionalOrganizer do
  subject(:organizer) { organizer_class.call(write: -> { create(:organization) }) }

  let(:organizer_class) do
    Class.new(ApplicationOrganizer) do
      include TransactionalOrganizer

      organize WriteTestRecord, FinalTestStep
    end
  end

  before do
    stub_const('WriteTestRecord', Class.new(ApplicationInteractor) do
      def call
        context.write.call
      end
    end)
    stub_const('FinalTestStep', Class.new(ApplicationInteractor) do
      def call; end
    end)
  end

  context 'when every step succeeds' do
    it { is_expected.to be_success }

    it 'commits what the steps wrote' do
      expect { organizer }.to change(Organization, :count).by(1)
    end
  end

  LateFailureHelpers::FAILURE_MODES.each do |failure, mode|
    context "when the last step fails with #{failure}" do
      before { make_step_fail(FinalTestStep, mode) }

      it 'rolls back what the previous steps wrote' do
        expect { call_through_late_failure { organizer } }.not_to change(Organization, :count)
      end
    end
  end

  context 'when called inside another transaction that goes on' do
    before { make_step_fail(FinalTestStep, :fail) }

    it 'rolls back only its own writes' do
      expect {
        ActiveRecord::Base.transaction do
          create(:organization)
          organizer
        end
      }.to change(Organization, :count).by(1)
    end
  end

  context 'when the enclosing transaction rolls back after a success' do
    it 'rolls back its writes with it' do
      expect {
        ActiveRecord::Base.transaction(requires_new: true) do
          organizer
          raise ActiveRecord::Rollback
        end
      }.not_to change(Organization, :count)
    end
  end
end
