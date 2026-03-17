class Admin::DataProvidersController < AdminController
  before_action :set_data_provider, only: %i[edit update]

  def index
    @data_providers = DataProvider.order(:name)
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
      success_message(title: t('.success'))
      redirect_to admin_data_providers_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def set_data_provider
    @data_provider = DataProvider.friendly.find(params[:id])
  end

  def data_provider_params
    params.expect(data_provider: %i[name link logo])
  end
end
