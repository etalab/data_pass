class CreateOrganizationFromSiret < ApplicationInteractor
  def call
    context.organization = find_or_create_organization
    update_organization_insee_payload
  end

  private

  def find_or_create_organization
    Organization.where(
      legal_entity_id: context.organization_siret,
      legal_entity_registry: 'insee_sirene'
    ).first_or_create!
  end

  def update_organization_insee_payload
    UpdateOrganizationINSEEPayload.call!(
      organization: context.organization
    )
  end
end
