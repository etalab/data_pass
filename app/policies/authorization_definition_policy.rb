class AuthorizationDefinitionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if registered_subdomain?
        scope.where(public: true, startable_by_applicant: true, id: registered_subdomain.authorization_definitions.map(&:id))
      else
        scope.where(public: true, startable_by_applicant: true)
      end
    end
  end

  def new?
    AuthorizationRequestCreationRules.for_definition(record, organization: current_organization, applicant: user).access_violation.nil?
  end
end
