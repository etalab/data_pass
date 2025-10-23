class CreateMessageTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :message_templates do |t|
      t.string :authorization_definition_uid, null: false
      t.integer :template_type, null: false
      t.string :title, null: false, limit: 50
      t.text :content, null: false

      t.timestamps
    end

    add_index :message_templates, %i[authorization_definition_uid template_type]
  end
end
