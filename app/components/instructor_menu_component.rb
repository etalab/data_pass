class InstructorMenuComponent < ApplicationComponent
  def initialize(show_drafts:, show_templates:, show_user_rights:)
    @show_drafts = show_drafts
    @show_templates = show_templates
    @show_user_rights = show_user_rights
  end

  def render?
    @show_drafts || @show_templates || @show_user_rights
  end

  attr_reader :show_drafts, :show_templates, :show_user_rights
end
