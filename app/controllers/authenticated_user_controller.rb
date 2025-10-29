class AuthenticatedUserController < ApplicationController
  include Authentication
  include AccessAuthorization

  impersonates :user

  before_action :refresh_current_organization_insee_data

  allow_unauthenticated_access only: :bypass_login

  def bypass_login
    return unless Rails.env.development?

    user = User.find_by(email: params[:email])
    sign_in(user, identity_federator: :bypass_login)

    redirect_to dashboard_path
  end

  def refresh_current_organization_insee_data
    return unless current_organization
    return if current_organization.last_insee_update_within_24h?

    UpdateOrganizationINSEEPayloadJob.perform_later(current_organization.id)
  end
end
