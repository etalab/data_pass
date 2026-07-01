class Organization < ApplicationRecord
  self.ignored_columns += %w[siret]

  LEGAL_CATEGORY_MAP = {
    '7210' => :commune,
    '7220' => :dept,
    '7230' => :region,
    '7343' => :communaute_urbaine,
    '7344' => :metropole,
    '7346' => :communaute_de_communes,
    '7348' => :communaute_agglomeration,
    '7361' => :ccas,
    '7367' => :cias,
  }.freeze
  private_constant :LEGAL_CATEGORY_MAP

  BLOC_COMMUNAL = %i[commune communaute_de_communes communaute_agglomeration].freeze
  private_constant :BLOC_COMMUNAL

  ENTITY_TYPE_MAP = {
    '7' => :administration,
    '4' => :gray_zone,
  }.freeze
  private_constant :ENTITY_TYPE_MAP

  validates :legal_entity_id, presence: true, uniqueness: { scope: :legal_entity_registry }
  validates :legal_entity_id, siret: true, if: -> { legal_entity_registry == 'insee_sirene' }

  has_many :organizations_users,
    dependent: :destroy
  has_many :users, through: :organizations_users

  has_many :authorization_requests,
    dependent: :restrict_with_exception

  has_many :authorizations,
    through: :authorization_requests

  has_many :active_authorization_requests,
    -> { active },
    dependent: :restrict_with_exception,
    class_name: 'AuthorizationRequest',
    inverse_of: :organization

  has_many :instructor_draft_requests,
    dependent: :destroy,
    inverse_of: :organization

  def siret
    return if foreign?

    legal_entity_id
  end

  def name
    return "L'organisation #{legal_entity_id} (issu de #{legal_entity_registry})" if foreign?
    return "#{nom} #{prenom}".strip if personne_physique?

    denomination || "l'organisation #{legal_entity_id} (nom inconnu)"
  end

  def denomination
    unite_legale['denominationUniteLegale']
  end

  def personne_physique?
    categorie_juridique == '1000'
  end

  def categorie_juridique
    unite_legale['categorieJuridiqueUniteLegale']
  end

  def activite_principale
    unite_legale['activitePrincipaleUniteLegale']
  end

  def legal_category
    LEGAL_CATEGORY_MAP.fetch(categorie_juridique, :other)
  end

  def entity_type
    ENTITY_TYPE_MAP.fetch(categorie_juridique.to_s[0], :other)
  end

  def bloc_communal?
    BLOC_COMMUNAL.include?(legal_category)
  end

  def association?
    categorie_juridique.to_s.start_with?('92')
  end

  def ccas_or_cias?
    %i[ccas cias].include?(legal_category)
  end

  def insee_payload
    self[:insee_payload] || {}
  end

  def code_commune_etablissement
    insee_payload.dig('etablissement', 'adresseEtablissement', 'codeCommuneEtablissement')
  end

  def last_insee_update_within_24h?
    return false if last_insee_payload_updated_at.blank?

    last_insee_payload_updated_at > 24.hours.ago
  end

  def foreign?
    legal_entity_registry != 'insee_sirene'
  end

  def closed?
    return false if insee_payload.blank?

    insee_latest_etablissement_period['etatAdministratifEtablissement'] == 'F'
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      legal_entity_id
      name
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  ransacker :name do |parent|
    payload_node = parent.table[:insee_payload]

    etablissement_node = Arel::Nodes::InfixOperation.new('->', payload_node, Arel::Nodes.build_quoted('etablissement'))
    unite_legale_node = Arel::Nodes::InfixOperation.new('->', etablissement_node, Arel::Nodes.build_quoted('uniteLegale'))

    Arel::Nodes::InfixOperation.new('->>', unite_legale_node, Arel::Nodes.build_quoted('denominationUniteLegale'))
  end

  def valid_authorizations_of(klass)
    authorizations.validated.where(authorization_request_class: klass.to_s)
  end

  private

  def unite_legale
    insee_payload.dig('etablissement', 'uniteLegale') || {}
  end

  def nom
    unite_legale['nomUniteLegale'].to_s
  end

  def prenom
    unite_legale['prenom1UniteLegale'].to_s
  end

  def insee_latest_etablissement_period
    return unless insee_payload['etablissement']

    insee_payload['etablissement']['periodesEtablissement'].find do |period|
      period['dateFin'].nil?
    end
  end
end
