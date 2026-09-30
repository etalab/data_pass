RSpec.describe RefreshStaleOrganizationsINSEEPayloadJob do
  subject(:refresh_stale_organizations_insee_payload_job) { described_class.perform_now }

  let!(:organization_without_payload) { create(:organization, last_insee_payload_updated_at: nil) }
  let!(:stale_organization) { create(:organization, last_insee_payload_updated_at: 42.days.ago) }
  let!(:fresh_organization) { create(:organization, last_insee_payload_updated_at: 1.hour.ago) }
  let!(:foreign_organization) { create(:organization, :foreign, last_insee_payload_updated_at: nil) }

  it 'enqueues a refresh for the organizations whose payload is missing or stale' do
    refresh_stale_organizations_insee_payload_job

    expect(UpdateOrganizationINSEEPayloadJob).to have_been_enqueued.with(organization_without_payload.id)
    expect(UpdateOrganizationINSEEPayloadJob).to have_been_enqueued.with(stale_organization.id)
  end

  it 'does not enqueue a refresh for the organizations whose payload is fresh' do
    refresh_stale_organizations_insee_payload_job

    expect(UpdateOrganizationINSEEPayloadJob).not_to have_been_enqueued.with(fresh_organization.id)
  end

  it 'does not enqueue a refresh for the foreign organizations' do
    refresh_stale_organizations_insee_payload_job

    expect(UpdateOrganizationINSEEPayloadJob).not_to have_been_enqueued.with(foreign_organization.id)
  end

  it 'enqueues a whole batch at once with the configured batch size' do
    freeze_time do
      refresh_stale_organizations_insee_payload_job

      expect(UpdateOrganizationINSEEPayloadJob).to have_been_enqueued.with(organization_without_payload.id).at(Time.current)
      expect(UpdateOrganizationINSEEPayloadJob).to have_been_enqueued.with(stale_organization.id).at(Time.current)
    end
  end

  it 'spreads the enqueued jobs over time once a batch is full' do
    Setting.set(:insee_refresh_batch_size, 1)

    freeze_time do
      refresh_stale_organizations_insee_payload_job

      expect(UpdateOrganizationINSEEPayloadJob).to have_been_enqueued.with(organization_without_payload.id).at(Time.current)
      expect(UpdateOrganizationINSEEPayloadJob).to have_been_enqueued.with(stale_organization.id).at(Setting.fetch(:insee_refresh_batch_interval).from_now)
    end
  end

  context 'when a refresh is already pending for an organization' do
    before do
      pending_refresh(organization_without_payload, finished_at: nil)
      pending_refresh(stale_organization, finished_at: 1.minute.ago)
    end

    it 'does not enqueue a second refresh for it, so that the pending one is not duplicated' do
      refresh_stale_organizations_insee_payload_job

      expect(UpdateOrganizationINSEEPayloadJob).not_to have_been_enqueued.with(organization_without_payload.id)
    end

    it 'still enqueues the organizations whose previous refresh is finished' do
      refresh_stale_organizations_insee_payload_job

      expect(UpdateOrganizationINSEEPayloadJob).to have_been_enqueued.with(stale_organization.id)
    end

    def pending_refresh(organization, finished_at:)
      GoodJob::Job.create!(
        active_job_id: SecureRandom.uuid,
        job_class: UpdateOrganizationINSEEPayloadJob.name,
        queue_name: 'insee',
        serialized_params: { 'job_class' => UpdateOrganizationINSEEPayloadJob.name, 'arguments' => [organization.id] },
        scheduled_at: 1.minute.from_now,
        finished_at:,
      )
    end
  end

  it 'caps how many organizations a single run enqueues' do
    Setting.set(:insee_refresh_max_organizations_per_run, 1)

    refresh_stale_organizations_insee_payload_job

    expect(UpdateOrganizationINSEEPayloadJob).not_to have_been_enqueued.with(stale_organization.id)
  end

  context 'when the INSEE calls are disabled by configuration' do
    before { Setting.set(:insee_calls_enabled, 'false') }

    it 'does not enqueue anything' do
      expect { refresh_stale_organizations_insee_payload_job }.not_to have_enqueued_job(UpdateOrganizationINSEEPayloadJob)
    end
  end

  context 'when INSEE calls are paused' do
    before { INSEECallsPause.pause! }

    it 'does not enqueue anything' do
      expect { refresh_stale_organizations_insee_payload_job }.not_to have_enqueued_job(UpdateOrganizationINSEEPayloadJob)
    end
  end
end
