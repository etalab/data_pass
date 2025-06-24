class AuthorizationDefinition::Stage
  include ActiveModel::Model

  attr_accessor :type, :next, :previous

  class NotExists < StandardError; end

  def exists?
    type.present?
  end

  def name
    I18n.t("authorization_request.stage.#{type}")
  end

  def next_stage_definition
    AuthorizationDefinition.find(next_stage[:id])
  rescue NotExists
    # do nothing
  end

  def next_stage_form
    return nil if next_stage_definition.blank?

    next_stage_definition.available_forms.find { |form| form.id == next_stage[:form_id] } || raise(ActiveRecord::RecordNotFound, "Couln't find form with id #{next_stage[:form_id]}")
  end

  def next_stage
    @next || (raise NotExists)
  end

  def next_stage?
    @next.present?
  end

  def previous_stage
    return {} unless previous

    {
      definition: AuthorizationDefinition.find(previous[:id]),
      form: AuthorizationRequestForm.find(previous[:form_id]),
    }
  end

  def previous_stage?
    @previous.present?
  end
end
