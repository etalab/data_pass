class AuthorizationRequestForm::Stage
  include ActiveModel::Model

  attr_accessor :definition
  attr_writer :previous_form_uid

  def previous_form_uid
    return nil unless definition.previous_stage?

    @previous_form_uid ||
      previous_default_form.uid
  end

  private

  def previous_default_form
    previous_stage_definition.default_form
  end

  def previous_stage_definition
    definition.previous_stage[:definition]
  end
end
