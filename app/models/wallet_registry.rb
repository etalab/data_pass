module WalletRegistry
  REFERENCE_TABLES = %w[
    wallet_registry_rulebooks
    wallet_registry_rulebook_formats
    wallet_registry_rulebook_claims
    wallet_registry_rulebook_claim_paths
  ].freeze

  def self.table_name_prefix
    'wallet_registry_'
  end
end
