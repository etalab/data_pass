class InstructorMenuComponent < ApplicationComponent
  def initialize(show_drafts:, show_templates:)
    @show_drafts = show_drafts
    @show_templates = show_templates
  end

  def render?
    @show_drafts || @show_templates
  end

  attr_reader :show_drafts, :show_templates
end
