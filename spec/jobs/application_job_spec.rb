RSpec.describe ApplicationJob do
  let(:job_class) { stub_const('TransactionProbeJob', Class.new(described_class) { def perform; end }) }
  let(:email) { AdminMailer.with(user: create(:user), old_roles: []).notify_user_roles_change }

  around do |example|
    previous_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = GoodJob::Adapter.new(execution_mode: :external)
    example.run
  ensure
    ActiveJob::Base.queue_adapter = previous_adapter
  end

  def in_rolled_back_transaction
    ActiveRecord::Base.transaction(requires_new: true) do
      yield
      raise ActiveRecord::Rollback
    end
  end

  it 'drops a job enqueued in a rolled back transaction' do
    expect { in_rolled_back_transaction { job_class.perform_later } }.not_to change(GoodJob::Job, :count)
  end

  it 'drops an email enqueued in a rolled back transaction' do
    email

    expect { in_rolled_back_transaction { email.deliver_later } }.not_to change(GoodJob::Job, :count)
  end

  it 'keeps a job enqueued in a committed transaction' do
    expect { ActiveRecord::Base.transaction(requires_new: true) { job_class.perform_later } }.to change(GoodJob::Job, :count).by(1)
  end
end
