class AuthorizationRequestPolicy < ApplicationPolicy
  def show?
    record.applicant == user
  end

  def update?
    record.applicant == user
  end

  def submit?
    %w[draft changes_requested].include?(record.status) &&
      record.applicant == user
  end
end
