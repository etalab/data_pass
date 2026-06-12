class AddBridgeDeclarationToHabilitationTypes < ActiveRecord::Migration[8.1]
  def change
    change_table :habilitation_types, bulk: true do |t|
      t.string :bridge_class_name
      t.jsonb :bridge_config, default: {}, null: false
    end
  end
end
