class Admin::MarkUserOrganizationAsVerifiedController < AdminController
  def new
    @organizations_user = find_organizations_user
    @user = @organizations_user.user
  end

  def edit
    @organizations_user = find_organizations_user
    @user = @organizations_user.user
  end

  def create
    @organizations_user = find_organizations_user

    organizer = Admin::MarkUserOrganizationAsVerified.call(
      admin: current_user,
      organizations_user: @organizations_user,
      reason: organizations_user_params[:verified_reason]
    )

    if organizer.success?
      success_message(title: t('.success'))
      redirect_to admin_user_organization_verifications_path(email: @organizations_user.user.email),
        status: :see_other
    else
      error_message(title: t('.error'), message: organizer.error)
      render :new, status: :unprocessable_content
    end
  end

  def update
    @organizations_user = find_organizations_user

    if @organizations_user.update(verified_reason: organizations_user_params[:verified_reason])
      success_message(title: t('.success'))
      redirect_to admin_user_organization_verifications_path(email: @organizations_user.user.email),
        status: :see_other
    else
      error_message(title: t('.error'))
      render :edit, status: :unprocessable_content
    end
  end

  private

  def find_organizations_user
    user_id, organization_id = extract_ids
    OrganizationsUser.find_by!(user_id:, organization_id:)
  end

  def extract_ids
    if params[:id]
      params[:id].split('-').map(&:to_i)
    else
      [params[:user_id], params[:organization_id]]
    end
  end

  def organizations_user_params
    params.expect(organizations_user: [:verified_reason])
  end
end
