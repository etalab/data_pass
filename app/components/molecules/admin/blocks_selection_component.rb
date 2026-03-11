class Molecules::Admin::BlocksSelectionComponent < ApplicationComponent
  def initialize(form:, habilitation_type:, title:)
    @form = form
    @habilitation_type = habilitation_type
    @title = title
  end

  private

  attr_reader :form, :habilitation_type, :title

  def checked_blocks
    habilitation_type.ordered_steps
  end
end
