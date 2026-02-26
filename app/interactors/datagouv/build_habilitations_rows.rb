class Datagouv::BuildHabilitationsRows < ApplicationInteractor
  CSV_HEADERS = [
    'Type de demande',
    'Dénomination unité légale',
    'SIRET',
    'Données concernées',
    'Fondement juridique'
  ].freeze

  def call
    context.rows = authorizations.map { |authorization| row_for(authorization) }
  end

  private

  def authorizations
    Authorization.active.includes(:request, :organization).order(:id)
  end

  def row_for(authorization)
    [
      request_type(authorization),
      authorization.organization.denomination.to_s,
      authorization.organization.siret.to_s,
      scopes_for(authorization),
      cadre_juridique_for(authorization)
    ]
  end

  def request_type(authorization)
    authorization.authorization_request_class.to_s.split('::').last
  end

  def scopes_for(authorization)
    value = authorization.data['scopes']
    return '' if value.blank?

    Array(value).join(', ')
  end

  def cadre_juridique_for(authorization)
    authorization.data['cadre_juridique_nature']
  end
end
