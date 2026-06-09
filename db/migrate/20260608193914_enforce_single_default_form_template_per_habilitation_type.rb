class EnforceSingleDefaultFormTemplatePerHabilitationType < ActiveRecord::Migration[8.1]
  def change
    remove_index :form_templates,
      column: %i[habilitation_type_id default],
      name: 'index_form_templates_on_habilitation_type_id_and_default'

    add_index :form_templates, :habilitation_type_id,
      unique: true,
      where: '"default"',
      name: 'index_one_default_form_template_per_habilitation_type'
  end
end
