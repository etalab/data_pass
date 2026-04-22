class FindOrCreateApplicantFromAPI < ApplicationInteractor
  def call
    context.applicant = find_or_initialize_user
    @applicant_was_new = context.applicant.new_record?
    assign_and_save!
  rescue ActiveRecord::RecordInvalid
    fail_with_error(:applicant_invalid, errors: context.applicant.errors.full_messages)
  end

  def rollback
    return unless @applicant_was_new && context.applicant&.persisted?

    context.applicant.delete
  end

  private

  def find_or_initialize_user
    User.find_or_initialize_by(email: normalized_email)
  end

  def normalized_email
    applicant_params[:email]&.downcase&.strip
  end

  def assign_and_save!
    context.applicant.assign_attributes(assignable_attributes)
    context.applicant.save!
  end

  def assignable_attributes
    applicant_params
      .except(:email)
      .compact
      .reject { |attr, _value| context.applicant.public_send(attr).present? }
  end

  def applicant_params
    context.applicant_params
  end
end
