class Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponent < ApplicationComponent
  def initialize(authorization_definition:)
    @authorization_definition = authorization_definition
  end

  private

  attr_reader :authorization_definition

  def kind_label
    I18n.t("activerecord.attributes.habilitation_type/kind/values.#{authorization_definition.kind}", default: authorization_definition.kind)
  end

  def boolean_label(value)
    value ? I18n.t('instruction.authorization_definitions.show.config_block.true') : I18n.t('instruction.authorization_definitions.show.config_block.false')
  end

  def feature_enabled?(feature)
    authorization_definition.feature?(feature)
  end

  def render_chip(key, &)
    render Molecules::Instruction::AuthorizationDefinition::ConfigChipComponent.new(
      label: t("instruction.authorization_definitions.show.config_block.#{key}")
    ) do |chip|
      chip.with_value(&)
    end
  end

  def render_boolean_chip(key, value)
    render_chip(key) { tag.span(boolean_label(value), class: 'config-chip__value') }
  end

  def render_kind_chip
    render_chip('fields.kind') { tag.code(kind_label, class: 'fr-code-inline') }
  end

  def render_support_email_chip
    render_chip('fields.support_email') { mail_to(support_email, support_email, class: 'fr-link') }
  end

  def render_access_link_chip
    render_chip('fields.access_link') { tag.code(access_link, class: 'fr-code-inline') }
  end

  delegate :kind, :startable_by_applicant, :unique, :access_link, :support_email, to: :authorization_definition
end
