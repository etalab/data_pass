class MigrateToMultiCountriesAttributesOnOrganizations < ActiveRecord::Migration[8.0]
  def up
    add_column :organizations, :legal_entity_id, :string
    change_column_null :organizations, :siret, true

    add_column :organizations, :legal_entity_registry, :string, default: 'insee_sirene', null: false
    add_column :organizations, :extra_legal_entity_infos, :jsonb

    remove_index :organizations, column: :siret

    say_with_time "Copying siret into new legal_entity_id column" do
      execute <<~SQL.squish
        UPDATE organizations
           SET legal_entity_id = siret;
      SQL
    end

    change_column_null :organizations, :legal_entity_id, false
    add_index :organizations, [:legal_entity_id, :legal_entity_registry], unique: true
  end

  def down
    say_with_time "Copying legal_entity_id into siret column" do
      execute <<~SQL.squish
        UPDATE organizations
           SET siret = legal_entity_id;
      SQL
    end

    remove_column :organizations, :legal_entity_id, :string
    remove_column :organizations, :legal_entity_registry, :string
    remove_column :organizations, :extra_legal_entity_infos, :jsonb

    change_column_null :organizations, :siret, true
    add_index :organizations, :siret, unique: true
  end
end
