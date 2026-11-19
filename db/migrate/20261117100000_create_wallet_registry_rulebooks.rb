class CreateWalletRegistryRulebooks < ActiveRecord::Migration[8.1]
  def change
    create_rulebooks
    create_rulebook_formats
    create_rulebook_claims
    create_rulebook_claim_paths
  end

  private

  def create_rulebooks
    create_table :wallet_registry_rulebooks do |t|
      t.string :source, :identifier, :version, :name, null: false
      t.string :category, :version_label, :documentation_url, :schema_uri, :keywords
      t.text :search_text, null: false, default: ''
      t.jsonb :source_details, null: false, default: {}
      t.boolean :provisional, null: false, default: true
      t.text :provisional_note
      t.datetime :retired_at
      t.timestamps
    end
    add_index :wallet_registry_rulebooks, %i[source identifier version], unique: true
  end

  def create_rulebook_formats
    create_table :wallet_registry_rulebook_formats do |t|
      t.references :rulebook, null: false, foreign_key: { to_table: :wallet_registry_rulebooks, on_delete: :cascade }
      t.string :format, null: false
      t.string :vct, :doctype
      t.timestamps
    end
    add_index :wallet_registry_rulebook_formats, %i[rulebook_id format], unique: true
  end

  def create_rulebook_claims
    create_table :wallet_registry_rulebook_claims do |t|
      t.references :rulebook, null: false, foreign_key: { to_table: :wallet_registry_rulebooks, on_delete: :cascade }
      t.string :identifier, :label, :requirement, :group_name, null: false
      t.text :description
      t.integer :position, null: false
      t.timestamps
    end
    add_index :wallet_registry_rulebook_claims, %i[rulebook_id identifier], unique: true
  end

  def create_rulebook_claim_paths
    create_table :wallet_registry_rulebook_claim_paths do |t|
      t.references :rulebook_claim, null: false, foreign_key: { to_table: :wallet_registry_rulebook_claims, on_delete: :cascade }
      t.references :rulebook_format, null: false, foreign_key: { to_table: :wallet_registry_rulebook_formats, on_delete: :cascade }
      t.string :path, array: true, null: false
      t.timestamps
    end
    add_index :wallet_registry_rulebook_claim_paths, %i[rulebook_claim_id rulebook_format_id], unique: true
  end
end
