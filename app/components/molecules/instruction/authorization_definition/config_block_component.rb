class Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponent < Atoms::ConfigBlockComponent
  def initialize(authorization_definition:)
    @authorization_definition = authorization_definition
  end

  private

  attr_reader :authorization_definition

  def rows
    [kind_row, *boolean_rows, support_email_row, access_link_row].compact
  end

  def kind_row
    return if kind.blank?

    { label: t('.fields.kind'), value: tag.strong(kind_label) }
  end

  def boolean_rows
    [*field_boolean_rows, *feature_boolean_rows]
  end

  def field_boolean_rows
    [
      boolean_row(t('.fields.startable_by_applicant'), startable_by_applicant),
      boolean_row(t('.fields.unique'), unique)
    ]
  end

  def feature_boolean_rows
    [
      boolean_row(t('.features.messaging'), feature_enabled?(:messaging)),
      boolean_row(t('.features.transfer'), feature_enabled?(:transfer)),
      boolean_row(t('.features.instructor_drafts'), feature_enabled?(:instructor_drafts)),
      boolean_row(t('.features.reopening'), feature_enabled?(:reopening))
    ]
  end

  def support_email_row
    return if support_email.blank?

    { label: t('.fields.support_email'), value: mail_to(support_email, support_email, class: 'fr-link') }
  end

  def access_link_row
    return if access_link.blank?

    { label: t('.fields.access_link'), value: tag.code(access_link, class: 'fr-code-inline') }
  end

  def kind_label
    I18n.t("activerecord.attributes.habilitation_type/kind/values.#{authorization_definition.kind}", default: authorization_definition.kind)
  end

  def feature_enabled?(feature)
    authorization_definition.feature?(feature)
  end

  delegate :kind, :startable_by_applicant, :unique, :access_link, :support_email, to: :authorization_definition
end
