class API::V1::WebhookCallsController < API::V1Controller
  before_action -> { doorkeeper_authorize! :read_webhooks }, only: :index
  before_action :set_webhook, only: :index

  def index
    webhook_calls = @webhook.calls
      .includes(:authorization_request)
      .then { |calls| filter_by_date_range(calls) }
      .order(created_at: :desc)
      .limit(maxed_limit(params[:limit], 100))

    render json: webhook_calls,
      each_serializer: API::V1::WebhookCallSerializer,
      status: :ok
  end

  private

  def set_webhook
    developer_definition_ids = current_user.authorization_definition_roles_as(:developer).map(&:id)
    @webhook = Webhook
      .where(authorization_definition_id: developer_definition_ids)
      .find(params[:webhook_id] || params[:id])
  end

  def filter_by_date_range(calls)
    return calls if start_time_param.blank? && end_time_param.blank?

    calls.between_dates(start_time, end_time)
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
