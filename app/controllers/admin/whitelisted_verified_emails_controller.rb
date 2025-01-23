class Admin::WhitelistedVerifiedEmailsController < AdminController
  def index
    @verified_emails = VerifiedEmail.where(status: 'whitelisted').order(created_at: :desc).page(params[:page]).per(50)
  end
end
