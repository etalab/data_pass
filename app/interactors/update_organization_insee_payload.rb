class UpdateOrganizationINSEEPayload < ApplicationInteractor
  def call
    return if organization.nil?
    return unless organization.insee_refresh_due?

    update_organization_insee_payload
  rescue INSEESireneAPIClient::EntityNotFoundError
    context.fail!(error: :insee_entity_not_found) unless tolerate_insee_entity_not_found?
  rescue AbstractINSEEAPIClient::UnavailableError, INSEESireneAPIClient::InvalidResponseError, Faraday::Error => e
    postpone_insee_payload_update(e)
  end

  private

  def update_organization_insee_payload
    if update_organization_now?
      UpdateOrganizationINSEEPayloadJob.new.perform(organization.id)
      organization.reload
    else
      UpdateOrganizationINSEEPayloadJob.perform_later(organization.id)
    end
  end

  def postpone_insee_payload_update(error)
    Sentry.capture_exception(error, level: :warning)

    UpdateOrganizationINSEEPayloadJob.perform_later(organization.id)
  end

  def update_organization_now?
    context.update_organization_insee_payload_now
  end

  def tolerate_insee_entity_not_found?
    context.tolerate_insee_entity_not_found
  end

  def organization
    context.organization
  end
end
