class AuthorizationRequestFormPolicy < ApplicationPolicy
  def new?
    creation_rules.startable? &&
      creation_rules.organization_active?
  end

  def create?
    new? && !creation_rules.unicity_violated?
  end

  private

  def creation_rules
    @creation_rules ||= AuthorizationRequestCreationRules.new(
      form: record,
      organization: current_organization,
      applicant: user
    )
  end
end
