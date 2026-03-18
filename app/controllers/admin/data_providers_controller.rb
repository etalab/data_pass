class Admin::DataProvidersController < AdminController
  before_action :set_data_provider, only: %i[edit update confirm_destroy destroy]
  before_action :authorize_data_provider!

  rescue_from Pundit::NotAuthorizedError, with: :data_provider_not_authorized

  def index
    @data_providers = DataProvider.order(:name)
    DataProvider.preload_linked_habilitation_types!(@data_providers)
  end

  def new
    @data_provider = DataProvider.new
  end

  def create
    organizer = Admin::CreateDataProvider.call(
      admin: current_user,
      params: data_provider_params,
    )

    @data_providers = DataProvider.order(:name)
    @data_provider = organizer.data_provider

    turbo_frame_request? ? handle_inline_create(organizer) : handle_standalone_create(organizer)
  end

  def edit; end

  def update
    organizer = Admin::UpdateDataProvider.call(
      admin: current_user,
      data_provider: @data_provider,
      params: data_provider_params,
    )

    if organizer.success?
      success_message(title: t('.success'))
      redirect_to admin_data_providers_path
    else
      error_message(title: t('.error'))
      render :edit, status: :unprocessable_content
    end
  end

  def confirm_destroy; end

  def destroy
    organizer = Admin::DestroyDataProvider.call(
      admin: current_user,
      data_provider: @data_provider,
    )

    if organizer.success?
      success_message(title: t('.success', name: @data_provider.name))
    else
      error_message_for(@data_provider, title: t('.error'))
    end

    redirect_to admin_data_providers_path
  end

  private

  def handle_inline_create(organizer)
    if organizer.success?
      respond_to do |format|
        format.turbo_stream
        format.html { render :create }
      end
    else
      @show_form = true
      render :create, formats: [:html], status: :unprocessable_content
    end
  end

  def handle_standalone_create(organizer)
    if organizer.success?
      success_message(title: t('admin.data_providers.create.success'))
      redirect_to admin_data_providers_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def authorize_data_provider!
    authorize(@data_provider || DataProvider)
  end

  def data_provider_not_authorized
    flash[:error] = { title: t('admin.data_providers.not_authorized') }
    redirect_to admin_data_providers_path
  end

  def set_data_provider
    @data_provider = DataProvider.friendly.find(params[:id])
  end

  def data_provider_params
    params.expect(data_provider: %i[name link logo])
  end
end
