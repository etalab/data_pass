class FindApplicant < ApplicationInteractor
  def call
    context.new_applicant = User.find_by(email: context.new_applicant_email&.downcase)

    return if context.new_applicant.present?

    context.fail!(error: :new_applicant_not_found)
  end
end
