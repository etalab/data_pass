class Molecules::Admin::ScopesEditorComponent < ApplicationComponent
  def initialize(form:, habilitation_type:, disabled: false)
    @form = form
    @habilitation_type = habilitation_type
    @disabled = disabled
  end

  def disabled?
    @disabled == true
  end

  def structural_fields_locked?
    @disabled == :structural || disabled?
  end

  private

  attr_reader :form, :habilitation_type

  def existing_scopes
    habilitation_type.scopes || []
  end

  def scope_field_errors(index, field)
    error_type = :"scope_#{field}_blank"
    habilitation_type.errors.where(:scopes, error_type, index:).map(&:message)
  end

  def scope_field_error_class(index, field)
    scope_field_errors(index, field).any? ? 'fr-input-group--error' : nil
  end

  def scopes_errors
    habilitation_type.errors.full_messages_for(:scopes)
  end
end
