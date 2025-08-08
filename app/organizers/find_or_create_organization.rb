class FindOrCreateOrganization < ApplicationOrganizer
  before do
    context.update_organization_insee_payload_now = true
  end

  organize FindOrCreateOrganizationModel,
    UpdateOrganizationINSEEPayload
end
