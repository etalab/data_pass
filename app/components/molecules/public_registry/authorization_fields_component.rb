class Molecules::PublicRegistry::AuthorizationFieldsComponent < ApplicationComponent
  Field = Data.define(:key, :value, :code)

  FIELD_KEYS = %i[denomination siret service provider scopes legal_basis validated_on number].freeze
  CODE_KEYS = %i[service scopes].freeze

  TERM_CLASSES = 'fr-col-12 fr-col-sm-4 fr-pr-2w fr-text--sm fr-text--bold fr-text-mention--grey fr-mb-0'.freeze
  DEFINITION_CLASSES = 'fr-col-12 fr-col-sm-8 fr-pl-0 fr-mb-0'.freeze

  def initialize(entry:)
    @entry = entry
  end

  def fields
    FIELD_KEYS.map { |key| Field.new(key, formatted_value(key), CODE_KEYS.include?(key)) }
  end

  def definition_classes(field)
    class_names(DEFINITION_CLASSES, 'r-code' => field.code)
  end

  def displayed_value(field)
    field.value.presence || tag.span(t('public_registry.not_provided'), class: 'fr-text-mention--grey')
  end

  private

  attr_reader :entry

  def formatted_value(key)
    case key
    when :scopes then entry.scopes.join(', ')
    when :validated_on then entry.validated_on && l(entry.validated_on)
    else entry.public_send(key)
    end
  end
end
