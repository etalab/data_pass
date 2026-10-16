class Admin::APIAccessGrantRevocationsController < AdminController
  before_action :set_grant
  before_action :redirect_when_already_revoked

  def new; end

  def create
    organizer = Admin::RevokeAPIAccess.call(admin: true_user, grant: @grant, reason: revoke_reason)

    if organizer.success?
      success_message(title: t('.success'))
      redirect_to admin_api_access_grants_path
    else
      error_message(title: @grant.errors.full_messages.to_sentence)
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_grant
    @grant = APIAccessGrant.find(params.expect(:api_access_grant_id))
  end

  def redirect_when_already_revoked
    return if @grant.active?

    flash[:error] = { title: t('admin.api_access_grant_revocations.already_revoked') }
    redirect_to admin_api_access_grants_path
  end

  def revoke_reason
    params.expect(api_access_grant: [:revoke_reason]).fetch(:revoke_reason)
  end
end
