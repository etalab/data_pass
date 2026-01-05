class Admin::UserOrganizationVerificationsController < AdminController
  def index
    @email = params[:email]
    @user = User.find_by(email: @email) if @email.present?
    @organizations_users = @user&.organizations_users&.includes(:organization) || []
  end
end
