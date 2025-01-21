class AuthorizationDefinition::Stage
  include ActiveModel::Model

  attr_accessor :type, :next, :previouses

  class NotExists < StandardError; end

  def exists?
    type.present?
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

  def previous_stage_form(authorization_request_class)
    previous_stages.find { |previous| previous[:definition].authorization_request_class == authorization_request_class }&.fetch(:form)
  end

  def next_stage
    @next || (raise NotExists)
  end

  def next_stage?
    @next.present?
  end

  def previous_stages
    (@previouses || []).map do |previous|
      {
        definition: AuthorizationDefinition.find(previous[:id]),
        form: AuthorizationRequestForm.find(previous[:form_id]),
      }
    end
  end
end
