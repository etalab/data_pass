class FindOrCreateOrganizationForAPI < ApplicationInteractor
  def call
    organization = Organization.find_or_initialize_by(
      legal_entity_id: context.siret,
      legal_entity_registry: 'insee_sirene'
    )
    @organization_was_new = organization.new_record?
    context.organization = organization
    save_organization
  end

  def rollback
    return unless @organization_was_new

    context.organization.destroy if context.organization&.persisted?
  end

  private

  def save_organization
    return if context.organization.save

    fail_with_error(:organization_invalid, errors: context.organization.errors.full_messages)
  end
end
