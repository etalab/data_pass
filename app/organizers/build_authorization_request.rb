class BuildAuthorizationRequest < ApplicationOrganizer
  before do
    context.authorization_request = context.authorization_request_form.authorization_request_class.new(
      form_uid: context.authorization_request_form.uid,
      applicant: context.applicant,
      organization: context.organization || context.applicant.current_organization,
    )
  end

  organize AssignDefaultDataToAuthorizationRequest
end
