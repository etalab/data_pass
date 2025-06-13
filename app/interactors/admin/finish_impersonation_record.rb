class Admin::FinishImpersonationRecord < ApplicationInteractor
  def call
    return if context.impersonation.finished_at.present?

    context.impersonation.finish!
  end
end
