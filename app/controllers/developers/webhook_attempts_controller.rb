class Developers::WebhookAttemptsController < DevelopersController
  before_action :set_webhook
  before_action :set_webhook_attempt, only: %i[show replay]

  def index
    authorize [:developer, @webhook], :show?
    @webhook_attempts = policy_scope([:developer, WebhookAttempt])
      .where(webhook: @webhook)
      .includes(:authorization_request)
      .order(created_at: :desc)
      .page(params[:page])
      .per(50)
  end

  def show
    authorize [:developer, @webhook_attempt]
  end

  def replay
    authorize [:developer, @webhook_attempt]
    result = Developer::ReplayWebhookAttempt.call(webhook_attempt: @webhook_attempt)

    if result.success?
      success_message(title: t('.success'))
      redirect_to developers_webhook_webhook_attempt_path(@webhook, result.webhook_attempt)
    else
      error_message(title: t('.error'), description: result.message)
      redirect_to developers_webhook_webhook_attempt_path(@webhook, @webhook_attempt)
    end
  end

  private

  def set_webhook
    @webhook = policy_scope([:developer, Webhook]).find(params[:webhook_id])
  end

  def set_webhook_attempt
    @webhook_attempt = policy_scope([:developer, WebhookAttempt]).find(params[:id])
  end

  def model_to_track_for_impersonation
    @webhook_attempt
  end
end
