class Datagouv::BuildHabilitationsRows < ApplicationInteractor
  CSV_HEADERS = [
    'API ou Service demandé',
    "Dénomination de l'unité légale du demandeur",
    'SIRET du demandeur',
    'Données demandées',
    "Fournisseur de l'API ou service",
    'Fondement juridique',
    'Date de validation'
  ].freeze

  def call
    @provider_name_cache = {}
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
      fournisseur_for(authorization),
      cadre_juridique_for(authorization),
      date_validation_for(authorization)
    ]
  end

  def request_type(authorization)
    authorization.authorization_request_class.to_s.split('::').last
  end

  def fournisseur_for(authorization)
    slug = authorization.definition.provider_slug
    provider_name_for_slug(slug).to_s
  end

  def provider_name_for_slug(slug)
    return nil if slug.blank?

    @provider_name_cache[slug] ||= DataProvider.friendly.find(slug).name
  rescue ActiveRecord::RecordNotFound
    @provider_name_cache[slug] = nil
  end

  def date_validation_for(authorization)
    authorization.created_at&.strftime('%Y-%m-%d').to_s
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
