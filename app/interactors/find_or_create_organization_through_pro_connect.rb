class FindOrCreateOrganizationThroughProConnect < ApplicationInteractor
  include ProConnectPayloads

  def call
    context.organization = find_or_initialize_organization
    assign_attributes
    context.organization.save!
  end

  private

  def find_or_initialize_organization
    Organization.where(
      legal_entity_id: raw_info_payload['siret'],
      legal_entity_registry: 'insee_sirene',
    ).first_or_initialize
  end

  def assign_attributes
    context.organization.assign_attributes(
      proconnect_payload: organization_attributes,
      last_proconnect_updated_at: DateTime.now,
    )
  end

  def organization_attributes
    {
      'siret' => raw_info_payload['siret']
    }
  end
end
