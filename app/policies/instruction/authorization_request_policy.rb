class Instruction::AuthorizationRequestPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(type: current_user_instructor_types)
    end

    def current_user_instructor_types
      current_user_instructor_roles.map do |scope|
        "AuthorizationRequest::#{scope.split(':').first.classify}"
      end
    end

    def current_user_instructor_roles
      user.roles.select do |scope|
        scope.end_with?(':instructor')
      end
    end
  end
end
