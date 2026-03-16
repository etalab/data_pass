class Datagouv::BuildHabilitationsRows < ApplicationInteractor
  CSV_HEADERS = [
    "Fournisseur de l'API ou service",
    'API ou Service demandé',
    'SIRET du demandeur',
    "Dénomination de l'unité légale du demandeur",
    'Données demandées',
    'Fondement juridique',
    'Date de validation'
  ].freeze

  before do
    @provider_name_cache = {}
    context.authorizations ||= Authorization.active.includes(:request, :organization).order(:id)
  end

  def call
    context.rows = context.authorizations.map { |authorization| row_for(authorization) }
  end

  private

  def row_for(authorization)
    [
      fournisseur_for(authorization),
      request_type(authorization),
      authorization.organization.siret,
      authorization.organization.denomination,
      scopes_for(authorization),
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
