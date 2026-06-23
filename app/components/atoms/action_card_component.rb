class Atoms::ActionCardComponent < ApplicationComponent
  def initialize(title:, description:, link:, detail: nil, icon: nil)
    @title = title
    @description = description
    @link = link
    @detail = detail
    @icon = icon
  end

  private

  attr_reader :title, :description, :link, :detail, :icon

  def detail_classes
    classes = ['fr-card__detail']
    classes << icon if icon
    classes.join(' ')
  end
end
