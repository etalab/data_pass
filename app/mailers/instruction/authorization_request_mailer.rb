class Instruction::AuthorizationRequestMailer < AbstractInstructionMailer
  def submit
    @authorization_request = params[:authorization_request]
    @user = params[:user]

    mail(to: @user.email, subject: t('.subject'))
  end

  def reopening_submit
    @authorization_request = params[:authorization_request]
    @user = params[:user]

    mail(to: @user.email, subject: t('.subject'))
  end
end
