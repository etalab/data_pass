class API::V1::WebhookAttemptsController < API::V1Controller
  before_action -> { doorkeeper_authorize! :read_webhooks }, only: :index
  before_action :set_webhook, only: :index

  def index
    webhook_attempts = @webhook.attempts
      .includes(:authorization_request)
      .then { |attempts| filter_by_date_range(attempts) }
      .order(created_at: :desc)
      .limit(maxed_limit(params[:limit], 100))

    render json: webhook_attempts,
      each_serializer: API::V1::WebhookAttemptSerializer,
      status: :ok
  end

  private

  def set_webhook
    developer_definition_ids = current_user.authorization_definition_roles_as(:developer).map(&:id)
    @webhook = Webhook
      .where(authorization_definition_id: developer_definition_ids)
      .find(params[:webhook_id] || params[:id])
  end

  def filter_by_date_range(attempts)
    return attempts if start_time_param.blank? && end_time_param.blank?

    attempts.between_dates(start_time, end_time)
  end

  def start_time
    start_time_param.present? ? Time.zone.parse(start_time_param) : Time.zone.at(0)
  end

  def end_time
    end_time_param.present? ? Time.zone.parse(end_time_param) : Time.zone.now
  end

  def start_time_param
    params[:start_time]
  end

  def end_time_param
    params[:end_time]
  end
end
