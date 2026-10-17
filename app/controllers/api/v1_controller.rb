class API::V1Controller < APIController
  include APIPagination

  rescue_from Doorkeeper::Errors::BaseResponseError, with: :render_generic_error
  rescue_from Doorkeeper::Errors::TokenUnknown, with: :render_unauthorized_error
  rescue_from Doorkeeper::Errors::TokenExpired, with: :render_expired_token_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_error
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing_error
  rescue_from Doorkeeper::Errors::TokenForbidden, with: :render_missing_scope_error
  rescue_from Pundit::NotAuthorizedError, with: :render_pundit_error

  protected

  def render_not_found_error
    render_error(404, title: 'Non trouvé', detail: 'La ressource demandée est introuvable.')
  end

  def render_unauthorized_error
    render_error(401, title: 'Non autorisé', detail: "Un jeton d'accès est requis mais absent dans les en-têtes de la requête.", source: { pointer: 'headers/Authorization' })
  end

  def render_expired_token_error
    render_error(401, title: 'Jeton expiré', detail: 'Le jeton d’accès a expiré. Veuillez en obtenir un nouveau.', source: { pointer: 'headers/Authorization' })
  end

  def render_generic_error
    render_error(422, title: 'Entité non traitable', detail: 'Un problème est survenu lors du traitement de la requête.')
  end

  def render_missing_scope_error
    render_api_access_denied(I18n.t('api_errors.api_access_denied.detail.missing_scope'))
  end

  def render_pundit_error(exception)
    detail_key = exception.policy.is_a?(APIAccessPolicy) ? exception.query.to_s.delete_suffix('?') : 'default'

    render_api_access_denied(I18n.t("api_errors.api_access_denied.detail.#{detail_key}", default: I18n.t('api_errors.api_access_denied.detail.default')))
  end

  def render_api_access_denied(detail)
    render_error(403, title: I18n.t('api_errors.api_access_denied.title'), detail:)
  end

  def render_parameter_missing_error(exception)
    render_error(
      400,
      title: 'Paramètre manquant',
      detail: "Le paramètre « #{exception.param} » est requis mais absent de la requête.",
      source: { pointer: "/#{exception.param}" },
    )
  end

  def render_error(http_code, title:, detail:, source: nil)
    render json: {
      errors: [
        {
          status: http_code.to_s,
          title:,
          detail:,
          source:,
        }.compact
      ]
    }, status: http_code
  end
end
