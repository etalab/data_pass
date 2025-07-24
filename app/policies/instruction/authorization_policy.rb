class Instruction::AuthorizationPolicy < ApplicationPolicy
  def show?
    reporter_for_record?
  end

  def revoke?
    show? &&
      instructor_for_record? &&
      record.can_revoke?
  end

  def transfer?
    show? &&
      instructor_for_record? &&
      record.persisted? &&
      (record.reopening? || record.state != 'draft')
  end

  def moderate?
    revoke?
  end

  private

  def instructor_for_record?
    user.instructor?(authorization_request_type)
  end

  def reporter_for_record?
    user.reporter?(authorization_request_type)
  end

  def authorization_request_type
    record.authorization_request_class.underscore.split('/').last
  end

  class Scope < Scope
    def resolve
      scope.where(authorization_request_class: current_user_reporter_types)
    end

    def current_user_reporter_types
      current_user_reporter_roles.map do |scope|
        "AuthorizationRequest::#{scope.split(':').first.classify}"
      end
    end

    def current_user_reporter_roles
      user.reporter_roles
    end
  end
end
