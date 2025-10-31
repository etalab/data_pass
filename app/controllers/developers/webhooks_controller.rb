class Developers::WebhooksController < DevelopersController
  before_action :set_webhook, only: %i[edit update destroy enable disable]

  def index
    authorize :webhook, :index?, policy_class: Developer::WebhookPolicy
    @webhooks = policy_scope(Webhook, policy_scope_class: Developer::WebhookPolicy::Scope).includes(:calls).order(created_at: :desc)
  end

  def new
    authorize Webhook, policy_class: Developer::WebhookPolicy
    @webhook = Webhook.new
    @authorization_definitions = current_user.authorization_definition_roles_as(:developer)
  end

  def create
    authorize Webhook, policy_class: Developer::WebhookPolicy
    result = Developer::CreateWebhook.call(webhook_params: webhook_params)

    if result.success?
      success_message(title: t('.success'))
      redirect_to developers_webhooks_path
    else
      @webhook = result.webhook
      @authorization_definitions = current_user.authorization_definition_roles_as(:developer)
      error_message(title: t('.error'))
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @webhook, policy_class: Developer::WebhookPolicy
    @authorization_definitions = current_user.authorization_definition_roles_as(:developer)
  end

  def update
    authorize @webhook, policy_class: Developer::WebhookPolicy
    result = Developer::UpdateWebhook.call(webhook: @webhook, webhook_params: webhook_params)

    if result.success?
      success_message(title: t('.success'))
      redirect_to developers_webhooks_path
    else
      @authorization_definitions = current_user.authorization_definition_roles_as(:developer)
      error_message(title: t('.error'))
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @webhook, policy_class: Developer::WebhookPolicy
    @webhook.destroy!
    success_message(title: t('.success'))
    redirect_to developers_webhooks_path
  end

  def enable
    authorize @webhook, policy_class: Developer::WebhookPolicy
    result = Developer::EnableWebhook.call(webhook: @webhook)

    if result.success?
      success_message(title: t('.success'))
    else
      error_description = build_webhook_error_description(result.webhook_test)
      error_message(title: t('.error'), description: error_description)
    end

    redirect_to developers_webhooks_path
  end

  def disable
    authorize @webhook, policy_class: Developer::WebhookPolicy
    @webhook.deactivate!
    success_message(title: t('.success'))
    redirect_to developers_webhooks_path
  end

  private

  def set_webhook
    @webhook = policy_scope(Webhook, policy_scope_class: Developer::WebhookPolicy::Scope).find(params[:id])
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
