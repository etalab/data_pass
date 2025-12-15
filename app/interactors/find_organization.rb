class FindOrganization < ApplicationInteractor
  def call
    context.new_organization = Organization.find_by(
      legal_entity_id: context.new_organization_siret,
      legal_entity_registry: 'insee_sirene'
    )

    return if context.new_organization.present?

    context.fail!(error: :new_organization_not_found)
  end
end
