class Developers::WebhookCallsController < DevelopersController
  before_action :set_webhook
  before_action :set_webhook_call, only: %i[show replay]

  def index
    authorize @webhook, :show?, policy_class: Developer::WebhookPolicy
    @webhook_calls = policy_scope(WebhookCall, policy_scope_class: Developer::WebhookCallPolicy::Scope)
      .where(webhook: @webhook)
      .includes(:authorization_request)
      .order(created_at: :desc)
      .page(params[:page])
      .per(50)
  end

  def show
    authorize @webhook_call, policy_class: Developer::WebhookCallPolicy
  end

  def replay
    authorize @webhook_call, policy_class: Developer::WebhookCallPolicy
    result = Developer::ReplayWebhookCall.call(webhook_call_id: @webhook_call.id)

    if result.success?
      success_message(title: t('.success'))
      redirect_to developers_webhook_webhook_call_path(@webhook, result.webhook_call)
    else
      error_message(title: t('.error'), description: result.message)
      redirect_to developers_webhook_webhook_call_path(@webhook, @webhook_call)
    end
  end

  private

  def set_webhook
    @webhook = policy_scope(Webhook, policy_scope_class: Developer::WebhookPolicy::Scope).find(params[:webhook_id])
  end

  def set_webhook_call
    @webhook_call = policy_scope(WebhookCall, policy_scope_class: Developer::WebhookCallPolicy::Scope).find(params[:id])
  end
end
