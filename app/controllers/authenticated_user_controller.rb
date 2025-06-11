class AuthenticatedUserController < ApplicationController
  include Authentication
  include AccessAuthorization
  include ImpersonationManagement

  impersonates :user

  before_action :refresh_current_organization_insee_data

  allow_unauthenticated_access only: :bypass_login

  def bypass_login
    return unless Rails.env.development?

    user = User.find_by(email: params[:email])
    sign_in(user)

    redirect_to dashboard_path
  end

  def refresh_current_organization_insee_data
    return unless current_organization

    UpdateOrganizationINSEEPayloadJob.perform_later(current_organization.id)
  end
end
