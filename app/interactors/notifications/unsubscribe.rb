class Notifications::Unsubscribe < ApplicationInteractor
  def call
    context.user.update!(setting_key => '0')

    NotificationPreferenceChange.create!(
      user: context.user,
      authorization_definition_id: context.definition_id,
      kind: context.kind,
      enabled: false,
      source: 'email_token',
    )
  end

  private

  def setting_key
    "instruction_#{toggle}_for_#{context.definition_id.underscore}"
  end

  def toggle
    context.kind == 'submit' ? 'submit_notifications' : 'messages_notifications'
  end
end
