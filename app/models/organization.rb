class Organization < ApplicationRecord
  validates :siret, presence: true, uniqueness: true, siret: true

  has_and_belongs_to_many :users

  def self.find_or_create_from_mon_compte_pro(payload)
    organization = Organization.find_or_initialize_by(siret: payload['siret'])
    organization.update!(mon_compte_pro_payload: payload, last_mon_compte_pro_updated_at: DateTime.now)
    organization
  end

  def raison_sociale
    mon_compte_pro_payload['label']
  end
end
