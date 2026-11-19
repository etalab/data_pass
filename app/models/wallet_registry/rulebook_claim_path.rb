class WalletRegistry::RulebookClaimPath < ApplicationRecord
  belongs_to :rulebook_claim, class_name: 'WalletRegistry::RulebookClaim', inverse_of: :paths
  belongs_to :rulebook_format, class_name: 'WalletRegistry::RulebookFormat', inverse_of: :claim_paths

  validates :path, presence: true
  validates :rulebook_format_id, uniqueness: { scope: :rulebook_claim_id }
end
