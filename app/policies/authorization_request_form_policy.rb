class AuthorizationRequestFormPolicy < ApplicationPolicy
  def new?
    creation_rules.access_violation.nil?
  end

  def create?
    creation_rules.creation_violation.nil?
  end

  private

  def creation_rules
    @creation_rules ||= AuthorizationRequestCreationRules.for_form(record, organization: current_organization, applicant: user)
  end
end
