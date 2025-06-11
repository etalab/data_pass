class Admin::FindUserForImpersonation < ApplicationInteractor
  def call
    context.target_user = find_user_by_email
    context.fail!(error: :user_not_found) unless context.target_user
  end

  private

  def find_user_by_email
    User.find_by(email: context.user_email)
  end
end
