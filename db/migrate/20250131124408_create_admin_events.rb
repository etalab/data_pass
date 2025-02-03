class CreateAdminEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_events do |t|
      t.string :name, null: false
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.references :entity, polymorphic: true, null: false
      t.json :before_attributes, default: {}
      t.json :after_attributes, default: {}

      t.timestamps
    end
  end
end
