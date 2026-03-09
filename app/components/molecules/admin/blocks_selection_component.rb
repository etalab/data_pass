class Molecules::Admin::BlocksSelectionComponent < ApplicationComponent
  def initialize(form:, habilitation_type:)
    @form = form
    @habilitation_type = habilitation_type
  end

  private

  attr_reader :form, :habilitation_type

  def checked_blocks
    habilitation_type.ordered_steps
  end
end
