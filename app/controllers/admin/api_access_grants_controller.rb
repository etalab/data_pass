class Admin::APIAccessGrantsController < AdminController
  before_action :load_form_collections, only: %i[new create]

  def index
    @grants = APIAccessGrant
      .includes(:data_provider)
      .order(granted_at: :desc)
      .page(params[:page])
      .per(50)
  end

  def new
    @grant = APIAccessGrant.new
  end

  def create
    organizer = Admin::GrantAPIAccess.call(admin: true_user, params: grant_params)

    if organizer.success?
      success_message(title: t('.success'))
      redirect_to admin_api_access_grants_path
    else
      @grant = organizer.grant
      error_message(title: @grant.errors.full_messages.to_sentence)
      render :new, status: :unprocessable_content
    end
  end

  private

  def load_form_collections
    @oauth_applications = Doorkeeper::Application.includes(:owner).order(:name)
    @data_providers = DataProvider.order(:name)
    @covered_application_ids_by_data_provider = covered_application_ids_by_data_provider
  end

  def covered_application_ids_by_data_provider
    slugs_by_application_id = @oauth_applications.to_h do |application|
      [application.id, APIAccessGrant.provider_slugs_covered_by_owner_of(application)]
    end

    @data_providers.to_h do |data_provider|
      [data_provider.id, slugs_by_application_id.select { |_id, slugs| slugs.include?(data_provider.slug) }.keys]
    end
  end

  def grant_params
    params.expect(api_access_grant: %i[oauth_application_id data_provider_id action grant_reason])
  end
end
