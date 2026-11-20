class CreateWalletRegistryIntendedUses < ActiveRecord::Migration[8.1]
  def change
    create_intended_uses
    create_intended_use_attestations
    create_intended_use_claims
  end

  private

  def create_intended_uses
    create_table :wallet_registry_intended_uses do |t|
      t.references :authorization_request, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, :privacy_policy_url
      t.text :purpose
      t.date :start_date, :end_date
      t.timestamps
    end
  end

  def create_intended_use_attestations
    create_table :wallet_registry_intended_use_attestations do |t|
      t.references :intended_use, null: false, foreign_key: { to_table: :wallet_registry_intended_uses, on_delete: :cascade }
      t.references :rulebook, null: false, foreign_key: { to_table: :wallet_registry_rulebooks }
      t.timestamps
    end
    add_index :wallet_registry_intended_use_attestations, %i[intended_use_id rulebook_id], unique: true, name: 'index_wallet_registry_intended_use_attestations_unicity'
  end

  def create_intended_use_claims
    create_table :wallet_registry_intended_use_claims do |t|
      t.references :intended_use_attestation, null: false, foreign_key: { to_table: :wallet_registry_intended_use_attestations, on_delete: :cascade }
      t.references :rulebook_claim, null: false, foreign_key: { to_table: :wallet_registry_rulebook_claims }
      t.timestamps
    end
    add_index :wallet_registry_intended_use_claims, %i[intended_use_attestation_id rulebook_claim_id], unique: true, name: 'index_wallet_registry_intended_use_claims_unicity'
  end
end
