class Admin::StatsController < AdminController
  layout 'application'

  def index; end

  def data
    start_date = parse_date(params[:start_date]) || 1.year.ago.to_date
    end_date = parse_date(params[:end_date]) || Date.current

    service = Stats::DataService.new(
      date_range: start_date..end_date,
      providers: parse_array_param(params[:providers]),
      authorization_types: parse_array_param(params[:authorization_types]),
      forms: parse_array_param(params[:forms]),
      include_breakdowns: true
    )

    render json: service.call
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def parse_date(date_string)
    return nil if date_string.blank?

    Date.parse(date_string)
  rescue Date::Error
    raise ArgumentError, 'Invalid date format'
  end

  def parse_array_param(param)
    return nil if param.blank?

    param.is_a?(Array) ? param : [param]
  end
end
