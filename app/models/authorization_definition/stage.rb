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

    next_stage_definition.available_forms.find { |form| form.id == next_stage[:form_id] } || raise(ActiveRecord::RecordNotFound, "Couln't find form with id #{stage[:next][:form_id]}")
  end

  def next_stage
    @next || (raise NotExists)
  end

  def next_stage?
    @next.present?
  end

  def previous_stages
    @previouses || []
  end
end