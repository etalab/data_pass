class FindInstructorForAPIApproval < ApplicationInteractor
  def call
    return fail_with_error(error_key) unless approver

    context.user = approver
  end

  private

  def approver
    @approver ||= definition.wallet_registry? ? find_verifier : find_instructor
  end

  def find_instructor
    definition.instructors.not_banned.find_by(email: normalized_email)
  end

  def find_verifier
    verifier = definition.verifiers.not_banned.find_by(email: normalized_email)

    verifier if verifier&.reporter?(definition.id)
  end

  def error_key
    definition.wallet_registry? ? :verifier_invalid : :instructor_invalid
  end

  def definition
    context.authorization_request.definition
  end

  def normalized_email
    context.instructor_email.to_s.strip.downcase.presence
  end
end
