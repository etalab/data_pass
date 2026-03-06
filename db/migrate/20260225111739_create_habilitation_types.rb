class CreateHabilitationTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :habilitation_types do |t|
      t.string :slug, null: false, index: { unique: true }
      t.string :name, null: false
      t.text :description
      t.string :link
      t.string :access_link
      t.string :cgu_link
      t.string :support_email
      t.string :kind, null: false, default: 'api'
      t.references :data_provider, null: false, foreign_key: true
      t.jsonb :scopes, null: false, default: []
      t.jsonb :blocks, null: false, default: []
      t.jsonb :features, null: false, default: {}
      t.jsonb :contact_types, null: false, default: []
      t.jsonb :custom_labels, null: false, default: {}
      t.text :form_introduction
      t.timestamps
    end
  end
end
