class API::V1Controller < APIController
  include APIPagination

  rescue_from Doorkeeper::Errors::TokenUnknown, with: :render_unauthorized_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_error

  before_action :doorkeeper_authorize!

  protected

  def render_not_found_error
    render_error(404, title: 'Non trouvé', detail: 'La ressource demandée est introuvable.')
  end

  def render_unauthorized_error
    render_error(401, title: 'Non autorisé', detail: "Un jeton d'accès est requis mais absent dans les en-têtes de la requête.", source: { pointer: 'headers/Authorization' })
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
