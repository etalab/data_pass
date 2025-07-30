class OrganizationsController < AuthenticatedUserController
  def new
    @organization = Organization.new

    authorize @organization
  end

  def create
    authorize Organization, :new?

    organizer = FindOrCreateOrganization.call(
      organization_params: {
        legal_entity_id: organization_params[:siret],
        legal_entity_registry: 'insee_sirene'
      },
    )
    @organization = organizer.organization

    if organizer.success?
      redirect_to organization_path(siret: @organization.siret)
    else
      error_message(title: t(".error.#{organizer.error}", siret: organization_params[:siret]))

      render :new, status: :unprocessable_entity
    end
  end

  def show
    @organization = Organization.find_by(legal_entity_id: params[:siret], legal_entity_registry: 'insee_sirene').decorate
  end

  private

  def organization_params
    params.expect(organization: [:siret])
  end

  def model_to_track_for_impersonation
    @organization
  end
end
