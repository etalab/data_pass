class User::OrganizationsController < AuthenticatedUserController
  layout 'application'

  def index
    @organizations_users = current_user.organizations_users.includes(:organization).order(current: :desc, verified: :desc)
  end

  def create
    @organization = extract_organization

    if @organization
      authorize @organization
      add_to_organization(@organization)

      success_message(title: t('.success', siret: @organization.siret, name: @organization.name))

      redirect_to dashboard_path
    else
      error_message(title: t('.error.not_found', siret: organization_params[:siret]))

      redirect_to new_organization_path,
        status: :unprocessable_content
    end
  end

  def set_as_current
    organization = extract_organization(siret: params[:id])
    user_organization = current_user.organizations_users.find_by!(organization_id: organization.id)

    user_organization.set_as_current!

    redirect_to dashboard_path
  end

  private

  def extract_organization(siret: organization_params[:siret])
    Organization.find_by!(
      legal_entity_id: siret,
      legal_entity_registry: 'insee_sirene',
    )
  end

  def add_to_organization(organization)
    current_user.add_to_organization(
      organization,
      current: true,
      verified: false,
      identity_provider_uid: current_identity_provider.id,
      identity_federator: 'pro_connect'
    )
    current_user.reload.current_organization_user.update!(manual: true)
  end

  def current_identity_provider
    current_user.current_identity_provider
  end

  def organization_params
    params.expect(organization: [:siret])
  end

  def model_to_track_for_impersonation
    @organization
  end
end
