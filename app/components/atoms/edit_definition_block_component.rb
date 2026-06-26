class Atoms::EditDefinitionBlockComponent < ApplicationComponent
  def initialize(title:, title_tag: :h2, static_block: false, can_edit: false, side_panel_id: nil, block_card_class: nil) # rubocop:disable Metrics/ParameterLists
    @title = title
    @title_tag = title_tag
    @static_block = static_block
    @can_edit = can_edit
    @side_panel_id = side_panel_id
    @block_card_class = block_card_class
  end

  private

  attr_reader :title, :title_tag, :side_panel_id, :block_card_class

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
