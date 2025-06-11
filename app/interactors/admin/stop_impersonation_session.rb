class Admin::StopImpersonationSession < ApplicationInteractor
  def call
    context.session.delete(:impersonated_user_id)
    context.session.delete(:impersonation_id)
  end
end
