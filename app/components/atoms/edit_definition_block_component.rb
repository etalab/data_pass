class Atoms::EditDefinitionBlockComponent < ApplicationComponent
  def initialize(title:, static_block: false, block_card_class: nil)
    @title = title
    @static_block = static_block
    @block_card_class = block_card_class
  end

  private

  attr_reader :title, :block_card_class

  def static_block?
    @static_block
  end

  def title_id
    "definition-block-#{title.parameterize}"
  end
end
