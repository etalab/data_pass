class WalletRegistry::Rulebook < ApplicationRecord
  SOURCES = %w[eu_catalog national custom].freeze

  has_many :formats, -> { order(:id) }, class_name: 'WalletRegistry::RulebookFormat', inverse_of: :rulebook, dependent: :destroy
  has_many :claims, -> { order(:position) }, class_name: 'WalletRegistry::RulebookClaim', inverse_of: :rulebook, dependent: :destroy

  validates :source, inclusion: { in: SOURCES }
  validates :identifier, :version, :name, presence: true
  validates :version, uniqueness: { scope: %i[source identifier] }

  scope :available, -> { where(retired_at: nil) }
  scope :search, ->(query) { where('search_text LIKE ?', "%#{sanitize_sql_like(normalize_search(query))}%") if query.present? }
  scope :for_catalog, -> { available.includes(:formats, :claims).order(:name) }

  def self.normalize_search(text)
    I18n.transliterate(text.to_s, replacement: ' ').downcase.squish
  end

  def groups
    claims.group_by(&:group_name).map { |name, group_claims| { name:, claims: group_claims } }
  end

  def format_labels
    formats.map(&:label)
  end

  def retired?
    retired_at.present?
  end

  def refresh_search_text!
    update!(search_text: self.class.normalize_search([name, keywords, *claims.map(&:label)].join(' ')))
  end
end
