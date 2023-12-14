class AuthorizationRequestPolicy < ApplicationPolicy
  def show?
    record.applicant == user
  end

  def update?
    record.applicant == user &&
      record.in_draft? &&
      record.applicant == user
  end

  def submit?
    record.persisted? &&
      record.in_draft? &&
      record.applicant == user
  end
end
