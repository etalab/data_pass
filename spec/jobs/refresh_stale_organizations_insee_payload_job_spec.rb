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
