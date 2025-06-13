class FindOrCreateOrganizationThroughProConnect < ApplicationInteractor
  include ProConnectPayloads

  def call
    context.organization = find_or_initialize_organization
    context.organization.assign_attributes(organization_attributes)
    context.organization.save!
  end

  private

  def find_or_initialize_organization
    Organization.where(
      legal_entity_id: raw_info_payload['siret'],
      legal_entity_registry: 'insee_sirene',
    ).first_or_initialize
  end

  def organization_attributes
    {
      proconnect_payload: proconnect_organization_attributes,
      last_proconnect_updated_at: DateTime.now,
    }
  end

  def proconnect_organization_attributes
    {
      'siret' => raw_info_payload['siret']
    }
  end
end
