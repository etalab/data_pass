class Organization < ApplicationRecord
  validates :siret, presence: true, uniqueness: true, siret: true

  validates :mon_compte_pro_payload, presence: true
  validates :last_mon_compte_pro_updated_at, presence: true

  has_and_belongs_to_many :users

  has_many :authorization_requests,
    dependent: :restrict_with_exception

  def raison_sociale
    mon_compte_pro_payload['label']
  end
end
