class Organization < ApplicationRecord
  self.ignored_columns += %w[siret]

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
    denomination || "l'organisation #{legal_entity_id} (nom inconnu)"
  end

  def denomination
    insee_payload.dig('etablissement', 'uniteLegale', 'denominationUniteLegale')
  end

  def insee_payload
    self[:insee_payload] || {}
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

  def insee_latest_etablissement_period
    return unless insee_payload['etablissement']

    insee_payload['etablissement']['periodesEtablissement'].find do |period|
      period['dateFin'].nil?
    end
  end
end
