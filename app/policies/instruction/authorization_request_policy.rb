class Instruction::AuthorizationRequestPolicy < ApplicationPolicy
  def show?
    reporter_for_record?
  end

  def refuse?
    show? &&
      instructor_for_record? &&
      record.can_refuse?
  end

  def revoke?
    show? &&
      record.can_revoke?
  end

  def request_changes?
    show? &&
      instructor_for_record? &&
      record.can_request_changes?
  end

  def approve?
    show? &&
      instructor_for_record? &&
      record.can_approve?
  end

  def archive?
    show? &&
      instructor_for_record? &&
      record.can_archive?
  end

  def send_message?
    show? &&
      instructor_for_record? &&
      !record.validated?
  end

  private

  def instructor_for_record?
    user.instructor?(authorization_request_type)
  end

  def reporter_for_record?
    user.reporter?(authorization_request_type)
  end

  def authorization_request_type
    record.type.underscore.split('/').last
  end

  class Scope < Scope
    def resolve
      scope.where(type: current_user_reporter_types)
    end

    def current_user_reporter_types
      current_user_reporter_roles.map do |scope|
        "AuthorizationRequest::#{scope.split(':').first.classify}"
      end
    end

    def current_user_reporter_roles
      user.roles.select do |scope|
        scope.end_with?(':reporter') ||
          scope.end_with?(':instructor')
      end
    end
  end
end
