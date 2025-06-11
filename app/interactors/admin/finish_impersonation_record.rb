class Admin::FinishImpersonationRecord < ApplicationInteractor
  def call
    return unless context.impersonation

    context.impersonation.finish!
  end
end
