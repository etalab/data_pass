class Notifications::Unsubscribe < ApplicationInteractor
  def call
    context.already_unsubscribed = !context.user.public_send(setting_key)
    return if context.already_unsubscribed

    context.user.update!(setting_key => '0')
    log_preference_change
  end

  private

  def log_preference_change
    NotificationPreferenceChange.create!(
      user: context.user,
      authorization_definition_id: context.definition_id,
      kind: context.kind,
      enabled: false,
      source: 'email_token',
    )
  end

  def setting_key
    "instruction_#{toggle}_for_#{context.definition_id.underscore}"
  end

  def toggle
    context.kind == 'submit' ? 'submit_notifications' : 'messages_notifications'
  end
end
