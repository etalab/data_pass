class Admin::FindUserForImpersonation < ApplicationInteractor
  def call
    context.target_user = find_user_by_identifier
    context.fail!(error: :user_not_found) unless context.target_user
  end

  private

  def find_user_by_identifier
    if context.user_identifier.to_s.match?(/\A\d+\z/)
      User.find_by(id: context.user_identifier)
    else
      User.find_by(email: context.user_identifier)
    end
  end
end
