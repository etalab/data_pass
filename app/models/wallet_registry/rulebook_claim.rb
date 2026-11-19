class WalletRegistry::RulebookClaim < ApplicationRecord
  REQUIREMENTS = %w[mandatory optional_by_country optional_by_issuer].freeze

  belongs_to :rulebook, class_name: 'WalletRegistry::Rulebook', inverse_of: :claims
  has_many :paths, class_name: 'WalletRegistry::RulebookClaimPath', inverse_of: :rulebook_claim, dependent: :destroy

  validates :identifier, presence: true, uniqueness: { scope: :rulebook_id }
  validates :label, :group_name, :position, presence: true
  validates :requirement, inclusion: { in: REQUIREMENTS }

  def may_be_missing?
    requirement != 'mandatory'
  end

  def path_for(rulebook_format)
    paths.find { |claim_path| claim_path.rulebook_format_id == rulebook_format.id }&.path
  end

  def format_count
    paths.length
  end
end
