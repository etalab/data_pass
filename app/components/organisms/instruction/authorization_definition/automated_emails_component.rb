class Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponent < ApplicationComponent
  SCOPE = 'instruction.authorization_definition_emails'.freeze

  EmailItem = Data.define(:standard, :reopening)

  def initialize(authorization_definition:)
    @authorization_definition = authorization_definition
  end

  def event_groups
    authorization_definition.automated_emails.reject { |group| group.emails.empty? }
  end

  def email_items(group)
    group.emails.group_by { |email| [email.mailer, base_action(email)] }.map do |_key, emails|
      EmailItem.new(
        standard: emails.find { |email| !reopening?(email) } || emails.first,
        reopening: emails.find { |email| reopening?(email) }
      )
    end
  end

  def event_title(event)
    scoped_t("events.#{event}")
  end

  def event_subtitle(event)
    scoped_t("event_descriptions.#{event}")
  end

  def scoped_t(key)
    I18n.t("#{SCOPE}.#{key}")
  end

  attr_reader :authorization_definition

  private

  def reopening?(email)
    email.state[:reopening] == true
  end

  def base_action(email)
    email.action.delete_prefix('reopening_')
  end
end
