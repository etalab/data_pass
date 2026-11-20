class UpdateOrganizationINSEEPayload < ApplicationInteractor
  def call
    return if organization.nil?
    return unless insee_refresh_wanted?

    update_organization_insee_payload
  rescue INSEESireneAPIClient::EntityNotFoundError => e
    UpdateOrganizationINSEEPayloadJob.record_insee_failure(organization, e, level: :warning)
    context.fail!(error: :insee_entity_not_found) unless tolerate_insee_entity_not_found?
  rescue AbstractINSEEAPIClient::UnavailableError, INSEESireneAPIClient::InvalidResponseError, Faraday::Error => e
    postpone_insee_payload_update(e)
  end

  private

  def update_organization_insee_payload
    if update_organization_now?
      UpdateOrganizationINSEEPayloadJob.new.perform(organization.id, force: force_insee_refresh?)
      organization.reload
    else
      UpdateOrganizationINSEEPayloadJob.perform_later(organization.id)
    end
  end

  def postpone_insee_payload_update(error)
    Sentry.capture_exception(error, level: :warning)

    UpdateOrganizationINSEEPayloadJob.perform_later(organization.id)
  end

  def insee_refresh_wanted?
    return organization.insee_refresh_due? unless force_insee_refresh?

    !organization.foreign? && !organization.insee_skipped?
  end

  def force_insee_refresh?
    context.force_insee_refresh.present?
  end

  def update_organization_now?
    context.update_organization_insee_payload_now || force_insee_refresh?
  end

  def tolerate_insee_entity_not_found?
    context.tolerate_insee_entity_not_found
  end

  def organization
    context.organization
  end
end
