class Instruction::InstructorDraftRequestPolicy < ApplicationPolicy
  def enabled?
    authorization_definitions_with_instructor_draft_feature.any? do |definition|
      user.instructor?(definition.authorization_request_type)
    end
  end

  def show?
    user.instructor?(record.definition.authorization_request_type)
  end

  def start?
    show?
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end

  def invite?
    show? &&
      record.applicant.blank?
  end

  def invite_link?
    show? &&
      record.public_id.present?
  end

  private

  def authorization_definitions_with_instructor_draft_feature
    AuthorizationDefinition.all.select do |definition|
      definition.feature?('instructor_drafts', default: false)
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
