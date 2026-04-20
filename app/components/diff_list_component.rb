class DiffListComponent < ApplicationComponent
  attr_reader :entries

  def initialize(entries:)
    @entries = entries
  end

  def call
    content_tag(:ul) do
      entries.map { |entry| content_tag(:li, entry) }.join.html_safe
    end
  end

  def render?
    entries.any?
  end
end
