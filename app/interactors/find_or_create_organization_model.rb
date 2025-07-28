class FindOrCreateOrganizationModel < ApplicationInteractor
  def call
    context.organization = find_or_create_organization

    return if context.organization.valid?

    context.fail!(error: :invalid_organization_params)
  end

  def rollback
    context.organization.destroy if can_destroy?
  end

  private

  def find_or_create_organization
    find_organization ||
      create_organization
  end

  def find_organization
    context.organization = Organization.where(context.organization_params).first
  end

  def create_organization
    context.organization = Organization.create(context.organization_params)
  end

  def can_destroy?
    context.organization.persisted? &&
      context.organization.users.empty? &&
      context.organization.authorizations.empty?
  end
end
