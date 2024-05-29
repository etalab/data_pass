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
    mon_compte_pro_payload['label']
  end

  def categorie_juridique
    return unless insee_payload

    CategorieJuridique.find(insee_payload['etablissement']['uniteLegale']['categorieJuridiqueUniteLegale'])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      siret
    ]
  end
end
