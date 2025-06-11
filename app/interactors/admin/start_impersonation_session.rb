class Admin::StartImpersonationSession < ApplicationInteractor
  def call
    context.session[:impersonated_user_id] = context.target_user.id
    context.session[:impersonation_id] = context.impersonation.id
  end
end
