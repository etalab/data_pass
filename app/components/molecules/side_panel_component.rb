class Molecules::SidePanelComponent < ApplicationComponent
  def initialize(id:, title: nil, open: false)
    @id = id
    @title = title
    @open = open
    super()
  end

  private

  attr_reader :id, :title

  def open?
    @open
  end

  def container_classes
    ['side-panel-container', ('side-panel-container--open' if open?)].compact.join(' ')
  end

  def title_id
    "#{id}-title"
  end
end
