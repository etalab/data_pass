class Instruction::AuthorizationDefinitionPolicy < ApplicationPolicy
  def index?
    user.reporter?
  end

  def show?
    user.can_read?(record.id)
  end

  def initiate_request?
    record.instructor_drafts_enabled? &&
      user.can_instruct?(record.authorization_request_type)
  end

  def edit?
    user.can_manage?(record.id)
  end
end
