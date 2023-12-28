class AuthorizationRequestsController < AuthenticatedUserController
  def index
    @authorization_definitions = AuthorizationDefinition.indexable
  end

  def new
    @authorization_definition = AuthorizationDefinition.find(params[:id])

    if @authorization_definition.available_forms.one?
      redirect_to new_authorization_request_form_path(form_uid: @authorization_definition.available_forms.first.uid)
    else
      begin
        render @authorization_definition.id
      rescue ActionView::MissingTemplate
        render :new
      end
    end
  end
end
