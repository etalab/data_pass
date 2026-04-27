class Instruction::UserRightsController < InstructionController
  before_action :authorize_user_rights!, only: %i[index new create]
  before_action :set_target_user, only: %i[edit update destroy confirm_destroy]

  def index
    @managed_definitions = current_user.authorization_definition_roles_as(:manager)
    @users = User.with_any_role_on(@managed_definitions.map(&:id))
      .where.not(id: current_user.id)
      .includes(:organizations)
      .order(:email)
  end

  def new
    @form = Instruction::UserRightForm.new(manager: current_user, rights: [blank_right])
  end

  def create
    @form = Instruction::UserRightForm.new(manager: current_user, **form_params)
    @target_user = User.find_by(email: @form.email)
    return render_email_not_found if @target_user.nil?
    return render_failure(:new) unless @form.save_for(@target_user, actor: current_user)

    success_message(title: t('instruction.user_rights.create.success', email: @target_user.email))
    redirect_to instruction_user_rights_path
  end

  def edit
    @form = Instruction::UserRightForm.for_edit(manager: current_user, user: @target_user)
  end

  def update
    @form = Instruction::UserRightForm.new(manager: current_user, user: @target_user, **form_params.except(:email))
    return render_failure(:edit) unless @form.save_for(@target_user, actor: current_user)

    success_message(title: t('instruction.user_rights.update.success', email: @target_user.email))
    redirect_to instruction_user_rights_path
  end

  def confirm_destroy
    @modifiable_rights = Instruction::UserRightsView.new(manager: current_user, user: @target_user).modifiable
    render partial: 'confirm_destroy', layout: false
  end

  def destroy
    result = Instruction::UpdateUserRights.call(manager: current_user, user: @target_user, new_roles: [])

    if result.success?
      success_message(title: t('instruction.user_rights.destroy.success', email: @target_user.email))
    else
      error_message(title: t('instruction.user_rights.destroy.error'))
    end

    redirect_to instruction_user_rights_path
  end

  private

  def authorize_user_rights!
    authorize %i[instruction user_right]
  end

  def set_target_user
    @target_user = User.find(params[:id])
    authorize @target_user, :"#{action_name}?", policy_class: Instruction::UserRightPolicy
  end

  def render_email_not_found
    @form.errors.add(:email, :not_found)
    render :new, status: :unprocessable_content
  end

  def render_failure(view)
    error_message(title: t('instruction.user_rights.create.error')) if @form.organizer_failed?
    render view, status: :unprocessable_content
  end

  def form_params
    params
      .expect(instruction_user_right_form: [:email, { rights: [%i[scope role_type]] }])
      .to_h
      .symbolize_keys
  end

  def blank_right
    { scope: '', role_type: '' }
  end

  def model_to_track_for_impersonation
    @target_user || User.new
  end
end
