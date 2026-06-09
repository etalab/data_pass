class CreateFormTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :form_templates do |t|
      t.string :slug, null: false
      t.references :habilitation_type, null: false, foreign_key: true
      t.string :service_provider_id
      t.string :name
      t.text :description
      t.text :introduction
      t.string :use_case
      t.boolean :default, null: false, default: false
      t.boolean :public, null: false, default: true
      t.boolean :startable_by_applicant, null: false, default: true
      t.boolean :single_page_view, null: false, default: false
      t.jsonb :steps, null: false, default: []
      t.jsonb :static_blocks, null: false, default: []
      t.jsonb :scopes_config, null: false, default: {}
      t.jsonb :initialize_with, null: false, default: {}

      t.timestamps
    end

    add_index :form_templates, :slug, unique: true
    add_index :form_templates, %i[habilitation_type_id default]
  end
end
