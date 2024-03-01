class UpdateOrganizationINSEEPayload < ApplicationInteractor
  def call
    return if organization.nil?

    UpdateOrganizationINSEEPayloadJob.perform_later(organization.id)
  end

  private

  def organization
    context.organization
  end
end
