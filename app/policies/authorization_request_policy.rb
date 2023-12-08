class AuthorizationRequestPolicy < ApplicationPolicy
  def show?
    record.applicant == user
  end

  def update?
    record.applicant == user &&
      %w[draft changes_requested].include?(record.state) &&
      record.applicant == user
  end

  def submit?
    record.persisted? &&
      %w[draft changes_requested].include?(record.state) &&
      record.applicant == user
  end
end
