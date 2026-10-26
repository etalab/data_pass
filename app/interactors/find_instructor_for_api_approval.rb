class FindInstructorForAPIApproval < ApplicationInteractor
  def call
    instructor = context.authorization_request.definition.instructors.not_banned.find_by(email: normalized_email)

    return fail_with_error(:instructor_invalid) unless instructor

    context.user = instructor
  end

  private

  def normalized_email
    context.instructor_email.to_s.strip.downcase.presence
  end
end
