class Molecules::FormErrorSummaryComponent < ApplicationComponent
  def initialize(record:, field_ids: {})
    @record = record
    @field_ids = field_ids
  end

  def render?
    record.errors.any?
  end

  private

  attr_reader :record, :field_ids

  def errors
    record.errors.uniq(&:attribute)
  end

  def title
    t('.title', count: errors.size)
  end

  def anchor_for(error)
    "##{field_ids.fetch(error.attribute) { "#{record.model_name.param_key}_#{error.attribute}" }}"
  end

  def summary_for(error)
    model = record.model_name.element
    attribute = error.base.class.human_attribute_name(error.attribute)

    if I18n.exists?("molecules.form_error_summary_component.messages.#{model}.#{error.attribute}.#{error.type}")
      I18n.t("molecules.form_error_summary_component.messages.#{model}.#{error.attribute}.#{error.type}", attribute:)
    else
      I18n.t("molecules.form_error_summary_component.messages.#{model}.#{error.type}", attribute:, default: error.full_message)
    end
  end
end
