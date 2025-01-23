class Admin::WhitelistedVerifiedEmailsController < AdminController
  def index
    @verified_emails = VerifiedEmail.where(status: 'whitelisted').order(created_at: :desc).page(params[:page]).per(50)
  end

  def new
    @verified_email = VerifiedEmail.new
  end

  def create
    @verified_email = VerifiedEmail.new(verified_email_params)

    if @verified_email.save
      success_message(title: t('.success', verified_email_email: @verified_email.email))

      redirect_to admin_whitelisted_verified_emails_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def verified_email_params
    params.expect(verified_email: [:email]).merge(status: 'whitelisted')
  end
end
