class RefreshStaleOrganizationsINSEEPayloadJob < ApplicationJob
  def perform
    return unless AbstractINSEEAPIClient.calls_allowed?

    stale_organization_ids.each_slice(batch_size).with_index do |organization_ids, batch_index|
      enqueue_batch(organization_ids, batch_index)
    end
  end

  private

  def batch_size
    Setting.fetch(:insee_refresh_batch_size)
  end

  def batch_interval
    Setting.fetch(:insee_refresh_batch_interval)
  end

  def max_organizations_per_run
    Setting.fetch(:insee_refresh_max_organizations_per_run)
  end

  def stale_organization_ids
    Organization.needing_insee_refresh
      .where.not(id: organization_ids_already_pending)
      .limit(max_organizations_per_run)
      .pluck(:id)
  end

  def organization_ids_already_pending
    GoodJob::Job
      .where(job_class: UpdateOrganizationINSEEPayloadJob.name, finished_at: nil)
      .select(Arel.sql("(serialized_params->'arguments'->>0)::bigint"))
  end

  def enqueue_batch(organization_ids, batch_index)
    wait_until = (batch_interval * batch_index).from_now

    organization_ids.each do |organization_id|
      UpdateOrganizationINSEEPayloadJob.set(wait_until:).perform_later(organization_id)
    end
  end
end
