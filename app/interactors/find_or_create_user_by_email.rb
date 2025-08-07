class FindOrCreateUserByEmail < ApplicationInteractor
  def call
    context.user = User.find_or_create_by!(email: context.applicant_email) do |user|
      user.assign_attributes(context.user_attributes || {})
    end
  end
end
