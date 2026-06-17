class Notifications::Unsubscribe < ApplicationInteractor
  def call
    context.user.with_lock { unsubscribe }
  end

  private

  def unsubscribe
    context.already_unsubscribed = !context.user.public_send(setting_key)
    return if context.already_unsubscribed

    context.user.update!(setting_key => '0')
  end

  def setting_key
    "instruction_#{toggle}_for_#{context.definition_id.underscore}"
  end

  def toggle
    context.kind == 'submit' ? 'submit_notifications' : 'messages_notifications'
  end
end
