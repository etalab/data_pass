class UpdateOrganizationINSEEPayload < ApplicationInteractor
  def call
    return if organization.nil?

    if update_organization_now?
      UpdateOrganizationINSEEPayloadJob.new.perform(organization.id)
    else
      UpdateOrganizationINSEEPayloadJob.perform_later(organization.id)
    end
  rescue INSEESireneAPIClient::EntityNotFoundError
    context.fail!(error: :insee_entity_not_found)
  end

  private

  def update_organization_now?
    context.update_organization_insee_payload_now
  end

  def organization
    context.organization
  end
end
