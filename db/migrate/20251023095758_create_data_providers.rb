class CreateDataProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :data_providers do |t|
      t.string :slug, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :link, null: false

      t.timestamps
    end
  end
end
