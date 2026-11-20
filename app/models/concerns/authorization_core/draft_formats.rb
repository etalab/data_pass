module AuthorizationCore::DraftFormats
  extend ActiveSupport::Concern

  included do
    class_attribute :draft_format_rules, default: {}

    validate :draft_formats_respected
    before_validation :set_aside_badly_formatted_values, if: :draft_save?
  end

  class_methods do
    def draft_format(attribute, error_type, &check)
      self.draft_format_rules = draft_format_rules.merge(attribute => { error_type:, check: })
    end
  end

  def draft_set_aside_values
    @draft_set_aside_values || {}
  end

  def reveal_draft_set_aside_values!
    draft_set_aside_values.each do |attribute, value|
      public_send(:"#{attribute}=", value)
      errors.add(attribute, draft_format_rules.dig(attribute, :error_type))
    end
  end

  private

  def draft_save?
    validation_context == :save_within_wizard ||
      (new_record? && current_build_step.blank?)
  end

  def badly_formatted_attributes
    draft_format_rules.filter_map do |attribute, rule|
      value = public_send(attribute)
      attribute if value.present? && !rule[:check].call(value)
    end
  end

  def draft_formats_respected
    badly_formatted_attributes.each do |attribute|
      errors.add(attribute, draft_format_rules.dig(attribute, :error_type))
    end
  end

  def set_aside_badly_formatted_values
    newly_set_aside = badly_formatted_attributes.index_with { |attribute| public_send(attribute) }
    @draft_set_aside_values = draft_set_aside_values.merge(newly_set_aside)

    newly_set_aside.each_key do |attribute|
      public_send(:"#{attribute}=", attribute_in_database(:data)&.dig(attribute.to_s))
    end
  end
end
