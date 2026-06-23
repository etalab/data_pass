class Atoms::EditDefinitionBlockComponent < ApplicationComponent
  def initialize(title:, static_block: false, can_edit: false, side_panel_id: nil)
    @title = title
    @static_block = static_block
    @can_edit = can_edit
    @side_panel_id = side_panel_id
  end

  private

  attr_reader :title, :side_panel_id

  def static_block?
    @static_block
  end

  def can_edit?
    @can_edit
  end

  def title_id
    "definition-block-#{title.parameterize}"
  end

  def modify_button_title
    t('atoms.edit_definition_block_component.modify_button_title', title:)
  end
end
