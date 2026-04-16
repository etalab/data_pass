class Admin::FindUserByEmail < ApplicationInteractor
  def call
    context.target_user = User.find_by(email: context.user_email)
    context.fail!(error: :user_not_found) unless context.target_user
  end
end
