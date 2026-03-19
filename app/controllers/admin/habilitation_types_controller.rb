class Admin::HabilitationTypesController < AdminController
  before_action :set_habilitation_type, only: %i[show edit update destroy]
  before_action :authorize_habilitation_type!

  rescue_from Pundit::NotAuthorizedError, with: :habilitation_type_not_authorized

  def index
    @habilitation_types = HabilitationType.includes(:data_provider)
      .order(created_at: :desc)
      .page(params[:page]).per(50)

    HabilitationType.preload_requests_counts!(@habilitation_types)
  end

  def show; end

  def new
    @habilitation_type = HabilitationType.new(blocks: HabilitationType::DEFAULT_BLOCKS)
  end

  def create
    organizer = Admin::CreateHabilitationType.call(
      admin: current_user,
      params: habilitation_type_params,
    )

    if organizer.success?
      success_message(title: t('.success', name: organizer.habilitation_type.name))
      redirect_to admin_habilitation_types_path
    else
      @habilitation_type = organizer.habilitation_type
      error_message(title: t('.error'))
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    organizer = Admin::UpdateHabilitationType.call(
      admin: current_user,
      habilitation_type: @habilitation_type,
      params: habilitation_type_params,
    )

    if organizer.success?
      success_message(title: t('.success', name: @habilitation_type.name))
      redirect_to admin_habilitation_types_path
    else
      error_message(title: t('.error'))
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    organizer = Admin::DestroyHabilitationType.call(
      admin: current_user,
      habilitation_type: @habilitation_type,
    )

    if organizer.success?
      success_message(title: t('.success', name: @habilitation_type.name))
    else
      error_message_for(@habilitation_type, title: t('.error'))
    end

    redirect_to admin_habilitation_types_path
  end

  private

  def authorize_habilitation_type!
    authorize(@habilitation_type || HabilitationType)
  end

  def habilitation_type_not_authorized
    flash[:error] = { title: t('admin.habilitation_types.not_authorized') }
    redirect_to admin_habilitation_types_path
  end

  def set_habilitation_type
    @habilitation_type = HabilitationType.friendly.find(params[:id])
  end

  def habilitation_type_params
    permitted = params.expect(
      habilitation_type: [
        :name, :description, :data_provider_id, :kind, :form_introduction,
        :cgu_link, :access_link, :link, :support_email,
        { blocks: [], contact_types: [], scopes: [%i[name value group]] },
      ],
    )
    permitted
      .merge(blocks: (permitted[:blocks] || []).compact_blank)
      .merge(contact_types: (permitted[:contact_types] || []).compact_blank)
      .merge(scopes: (permitted[:scopes] || []).reject { |s| s.values.all?(&:blank?) })
  end
end
