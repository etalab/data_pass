class OrganizationsController < AuthenticatedUserController
  def new
    @organization = Organization.new
  end

  def create
    organizer = FindOrCreateOrganization.call(
      legal_entity_id: organization_params[:siret],
      legal_entity_registry: 'insee_sirene'
    )
    @organization = organizer.organization

    if organizer.success?
      render :show, status: :created
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.expect(organization: [:siret])
  end
end
