class AssignAPIAuthorizationRequestModel < ApplicationInteractor
  def call
    context.authorization_request = context.authorization_request_form.authorization_request_class.new(
      applicant: context.applicant,
      organization: context.organization,
      form_uid: context.authorization_request_form.uid
    )
  end
end
