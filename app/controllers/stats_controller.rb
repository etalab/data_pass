class StatsController < PublicController
  helper_method :user_signed_in?

  def index; end

  def filters
    providers = DataProvider.all.map do |provider|
      { slug: provider.slug, name: provider.name }
    end

    types = AuthorizationDefinition.all.map do |definition|
      {
        class_name: definition.authorization_request_class.name,
        name: definition.name,
        provider_slug: definition.provider&.slug
      }
    end

    forms = AuthorizationRequestForm.all.map do |form|
      {
        uid: form.uid,
        name: form.name,
        authorization_type: form.authorization_request_class.name
      }
    end

    render json: {
      providers: providers,
      types: types,
      forms: forms
    }
  end

  def data
    start_date = parse_date(params[:start_date]) || 1.year.ago.to_date
    end_date = parse_date(params[:end_date]) || Date.current

    service = Stats::DataService.new(
      date_range: start_date..end_date,
      providers: parse_array_param(params[:providers]),
      authorization_types: parse_array_param(params[:authorization_types]),
      forms: parse_array_param(params[:forms])
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
