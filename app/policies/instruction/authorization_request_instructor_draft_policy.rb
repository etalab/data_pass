class Instruction::AuthorizationRequestInstructorDraftPolicy < ApplicationPolicy
  def enable?
    %w[
      api_entreprise
      api_particulier
    ].any? do |authorization_definition_id|
      user.instructor?(authorization_definition_id)
    end
  end

  class Scope < Scope
    def resolve
      scope.where(authorization_request_class: current_user_instructor_types)
    end

    def current_user_instructor_types
      current_user_instructor_roles.map do |scope|
        "AuthorizationRequest::#{scope.split(':').first.classify}"
      end
    end

    def current_user_instructor_roles
      user.instructor_roles
    end
  end
end
