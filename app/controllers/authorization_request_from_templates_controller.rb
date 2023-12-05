class AuthorizationRequestFromTemplatesController < AuthenticatedUserController
  before_action :extract_authorization_request_form

  def index
    @authorization_request_templates = @authorization_request_form.templates
  end

  def create
    authorization_request_template = @authorization_request_form.templates.find { |template| template.id == params[:template_uid] }

    @authorization_request = @authorization_request_form.authorization_request_class.new(user_attributes.merge(authorization_request_template.attributes))
    @authorization_request.save!

    redirect_to authorization_request_path(form_uid: @authorization_request_form.uid, id: @authorization_request.id)
  end

  private

  # FIXME: L'organisation devrait être déterminée en amont
  def user_attributes
    {
      applicant: current_user,
      organization_id: current_user.organizations.first.id
    }
  end

  def extract_authorization_request_form
    @authorization_request_form = AuthorizationRequestForm.find(params[:form_uid])
  end
end
