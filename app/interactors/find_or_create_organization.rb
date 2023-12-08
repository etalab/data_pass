class FindOrCreateOrganization < ApplicationInteractor
  include MonCompteProPayloads

  def call
    context.organization = find_or_initialize_organization
    assign_attributes
    context.organization.save!
  end

  private

  def find_or_initialize_organization
    Organization.where(
      siret: info_payload['siret'],
    ).first_or_initialize
  end

  def assign_attributes
    context.organization.assign_attributes(
      mon_compte_pro_payload: organization_attributes,
      last_mon_compte_pro_updated_at: DateTime.now,
    )
  end

  def organization_attributes
    info_payload.slice(
      'label',
      'is_collectivite_territoriale',
      'is_commune',
      'is_external',
      'is_service_public',
    )
  end
end
