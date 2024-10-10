class Organization < ApplicationRecord
  validates :siret, presence: true, uniqueness: true, siret: true

  validates :mon_compte_pro_payload, presence: true
  validates :last_mon_compte_pro_updated_at, presence: true

  has_and_belongs_to_many :users

  has_many :authorization_requests,
    dependent: :restrict_with_exception

  has_many :authorizations,
    through: :authorization_requests

  has_many :active_authorization_requests,
    -> { not_archived },
    dependent: :restrict_with_exception,
    class_name: 'AuthorizationRequest',
    inverse_of: :organization

  def raison_sociale
    denomination
  end

  def code_commune
    insee_payload.dig('etablissement', 'adresseEtablissement', 'codeCommuneEtablissement')
  end

  def denomination
    insee_payload.dig('etablissement', 'uniteLegale', 'denominationUniteLegale')
  end

  def sigle_unite_legale
    insee_payload.dig('etablissement', 'uniteLegale', 'sigleUniteLegale')
  end

  def code_postal
    insee_payload.dig('etablissement', 'adresseEtablissement', 'codePostalEtablissement')
  end

  def libele_commune
    insee_payload.dig('etablissement', 'adresseEtablissement', 'libelleCommuneEtablissement')
  end

  def insee_payload
    self[:insee_payload] || {}
  end

  def categorie_juridique
    return if insee_payload.blank?

    CategorieJuridique.find(insee_payload['etablissement']['uniteLegale']['categorieJuridiqueUniteLegale'])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      siret
      raison_sociale
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  ransacker :raison_sociale do |parent|
    payload_node = parent.table[:insee_payload]

    etablissement_node = Arel::Nodes::InfixOperation.new('->', payload_node, Arel::Nodes.build_quoted('etablissement'))
    unite_legale_node = Arel::Nodes::InfixOperation.new('->', etablissement_node, Arel::Nodes.build_quoted('uniteLegale'))

    Arel::Nodes::InfixOperation.new('->>', unite_legale_node, Arel::Nodes.build_quoted('denominationUniteLegale'))
  end
end
