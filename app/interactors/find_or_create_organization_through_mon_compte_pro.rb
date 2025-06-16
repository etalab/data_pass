class FindOrCreateOrganizationThroughMonComptePro < ApplicationInteractor
  include MonCompteProPayloads

  def call
    context.organization = find_or_initialize_organization
    context.organization.assign_attributes(organization_attributes)
    context.organization.save!
  end

  private

  def find_or_initialize_organization
    Organization.where(
      legal_entity_id: info_payload['siret'],
      legal_entity_registry: 'insee_sirene',
    ).first_or_initialize
  end

  def organization_attributes
    {
      mon_compte_pro_payload: mon_compte_pro_organization_attributes,
      last_mon_compte_pro_updated_at: DateTime.now,
    }
  end

  def mon_compte_pro_organization_attributes
    info_payload.slice(
      'label',
      'is_collectivite_territoriale',
      'is_commune',
      'is_external',
      'is_service_public',
    )
  end
end
