class Developers::WebhookCallsController < DevelopersController
  before_action :set_webhook
  before_action :set_webhook_call, only: %i[show replay]

  def index
    authorize [:developer, @webhook], :show?
    @webhook_calls = policy_scope([:developer, WebhookCall])
      .where(webhook: @webhook)
      .includes(:authorization_request)
      .order(created_at: :desc)
      .page(params[:page])
      .per(50)
  end

  def show
    authorize [:developer, @webhook_call]
  end

  def replay
    authorize [:developer, @webhook_call]
    result = Developer::ReplayWebhookCall.call(webhook_call: @webhook_call)

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
    @webhook = policy_scope([:developer, Webhook]).find(params[:webhook_id])
  end

  def set_webhook_call
    @webhook_call = policy_scope([:developer, WebhookCall]).find(params[:id])
  end

  def model_to_track_for_impersonation
    @webhook_call
  end
end
