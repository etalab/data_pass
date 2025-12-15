class Developers::WebhooksController < DevelopersController
  before_action :set_webhook, only: %i[edit update destroy enable disable regenerate_secret show_secret]

  def index
    authorize %i[developer webhook], :index?
    @webhooks = policy_scope([:developer, Webhook]).includes(:attempts).order(created_at: :desc)
  end

  def new
    authorize [:developer, Webhook]
    @webhook = Webhook.new
    @authorization_definitions = current_user.authorization_definition_roles_as(:developer)
  end

  def create
    authorize [:developer, Webhook]
    result = Developer::CreateWebhook.call(webhook_params: webhook_params)

    if result.success?
      flash[:webhook_secret] = result.secret
      redirect_to show_secret_developers_webhook_path(result.webhook)
    else
      @webhook = result.webhook
      @authorization_definitions = current_user.authorization_definition_roles_as(:developer)
      error_message(title: t('.error'))
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize [:developer, @webhook]
    @authorization_definitions = current_user.authorization_definition_roles_as(:developer)
  end

  def update
    authorize [:developer, @webhook]
    result = Developer::UpdateWebhook.call(webhook: @webhook, webhook_params: webhook_params)

    if result.success?
      success_message(title: t('.success'))
      redirect_to developers_webhooks_path
    else
      @authorization_definitions = current_user.authorization_definition_roles_as(:developer)
      error_message(title: t('.error'))
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize [:developer, @webhook]
    @webhook.destroy!
    success_message(title: t('.success'))
    redirect_to developers_webhooks_path
  end

  def enable
    authorize [:developer, @webhook]
    result = Developer::EnableWebhook.call(webhook: @webhook)

    if result.success?
      success_message(title: t('.success'))

      redirect_to developers_webhooks_path
    else
      error_description = build_webhook_error_description(result.webhook_test)
      error_message(title: t('.error'), description: error_description)

      index

      render :index, status: :unprocessable_content
    end
  end

  def disable
    authorize [:developer, @webhook]
    @webhook.deactivate!
    success_message(title: t('.success'))
    redirect_to developers_webhooks_path
  end

  def regenerate_secret
    authorize [:developer, @webhook]
    result = Developer::RegenerateWebhookSecret.call(webhook: @webhook)

    if result.success?
      flash[:webhook_secret] = result.secret
      redirect_to show_secret_developers_webhook_path(@webhook)
    else
      error_message(title: t('.error'))
      redirect_to developers_webhooks_path, status: :unprocessable_content
    end
  end

  def show_secret
    authorize [:developer, @webhook]
    @secret = flash[:webhook_secret]

    redirect_to developers_webhooks_path if @secret.blank?
  end

  private

  def set_webhook
    @webhook = policy_scope([:developer, Webhook]).find(params[:id])
  end

  def webhook_params
    params.expect(webhook: [:authorization_definition_id, :url, { events: [] }])
  end

  def build_webhook_error_description(webhook_test)
    status_code = webhook_test[:status_code]
    response_body = webhook_test[:response_body]

    if status_code.present?
      "Code HTTP: #{status_code}\n#{response_body}"
    else
      response_body
    end
  end

  def model_to_track_for_impersonation
    @webhook
  end
end
