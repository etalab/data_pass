class FindOrCreateUserByEmail < ApplicationInteractor
  def call
    context.user = User.find_or_create_by(email: context.applicant_email) do |user|
      user.assign_attributes(context.user_attributes || {})
    end

    return if context.user.persisted?

    context.fail!(error: :user_invalid)
  end
end
