class Admin::UnmarkUserOrganizationAsVerifiedController < AdminController
  def destroy
    organizations_user = find_organizations_user

    if organizations_user.update(verified: false, verified_reason: nil)
      success_message(title: t('.success'))
    else
      error_message(title: t('.error'))
    end

    redirect_to admin_user_organization_verifications_path(email: organizations_user.user.email),
      status: :see_other
  end

  private

  def find_organizations_user
    user_id, organization_id = params[:id].split('-').map(&:to_i)
    OrganizationsUser.find_by!(user_id:, organization_id:)
  end
end
