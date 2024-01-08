class CreateInstructorModificationRequestModel < ApplicationInteractor
  def call
    context.instructor_modification_request = authorization_request.build_modification_request(
      instructor_modification_request_params
    )

    return if context.instructor_modification_request.save

    context.fail!
  end

  private

  def authorization_request
    context.authorization_request
  end

  def instructor_modification_request_params
    context.instructor_modification_request_params
  end
end
