class API::V1Controller < APIController
  include APIPagination

  before_action :reject_banned_token_owner

  rescue_from Doorkeeper::Errors::BaseResponseError, with: :render_generic_error
  rescue_from Doorkeeper::Errors::TokenUnknown, with: :render_unauthorized_error
  rescue_from Doorkeeper::Errors::TokenExpired, with: :render_expired_token_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_error
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing_error

  protected

  def reject_banned_token_owner
    return unless token_owner&.banned?

    render_error(403, :banned_token_owner)
  end

  def token_owner
    doorkeeper_token&.application&.owner
  end

  def render_not_found_error
    render_error(404, :not_found)
  end

  def render_unauthorized_error
    render_error(401, :token_missing, source: { pointer: 'headers/Authorization' })
  end

  def render_expired_token_error
    render_error(401, :token_expired, source: { pointer: 'headers/Authorization' })
  end

  def render_generic_error
    render_error(422, :generic)
  end

  def render_parameter_missing_error(exception)
    render_error(400, :parameter_missing, interpolations: { param: exception.param }, source: { pointer: "/#{exception.param}" })
  end

  def render_error(http_code, key, source: nil, interpolations: {})
    render json: {
      errors: [
        {
          status: http_code.to_s,
          title: I18n.t("api_errors.#{key}.title"),
          detail: I18n.t("api_errors.#{key}.detail", **interpolations),
          source:,
        }.compact
      ]
    }, status: http_code
  end
end
