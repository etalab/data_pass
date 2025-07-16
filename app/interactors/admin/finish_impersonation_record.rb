class Admin::FinishImpersonationRecord < ApplicationInteractor
  def call
    context.fail! if impersonation.nil?

    return if impersonation.finished_at.present?

    impersonation.finish!
  end

  private

  def impersonation
    context.impersonation = latest_unfinished_impersonation if context.impersonation.nil?

    context.impersonation
  end

  def latest_unfinished_impersonation
    @latest_unfinished_impersonation ||= Impersonation.where(
      admin: context.admin,
      finished_at: nil
    )
      .order(created_at: :desc)
      .first
  end
end
