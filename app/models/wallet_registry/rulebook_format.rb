class WalletRegistry::RulebookFormat < ApplicationRecord
  SD_JWT = 'dc+sd-jwt'.freeze
  MDOC = 'mso_mdoc'.freeze
  LABELS = { SD_JWT => 'SD-JWT VC', MDOC => 'mdoc' }.freeze

  belongs_to :rulebook, class_name: 'WalletRegistry::Rulebook', inverse_of: :formats
  has_many :claim_paths, class_name: 'WalletRegistry::RulebookClaimPath', inverse_of: :rulebook_format, dependent: :destroy

  validates :format, inclusion: { in: LABELS.keys }, uniqueness: { scope: :rulebook_id }
  validates :vct, presence: true, if: :sd_jwt?
  validates :doctype, presence: true, if: :mdoc?

  def label
    LABELS.fetch(format)
  end

  def sd_jwt?
    format == SD_JWT
  end

  def mdoc?
    format == MDOC
  end

  def meta
    sd_jwt? ? { 'vct_values' => [vct] } : { 'doctype_value' => doctype }
  end

  def credential_for(rulebook_claims)
    {
      'format' => format,
      'meta' => meta,
      'claims' => rulebook_claims.filter_map { |claim| claim.path_for(self) }.map { |path| { 'path' => path } }
    }
  end
end
