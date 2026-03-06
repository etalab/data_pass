class Molecules::Admin::ScopesEditorComponent < ApplicationComponent
  def initialize(form:, habilitation_type:)
    @form = form
    @habilitation_type = habilitation_type
  end

  private

  attr_reader :form, :habilitation_type

  def existing_scopes
    habilitation_type.scopes || []
  end
end
