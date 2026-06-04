class NotificationUnsubscribeToken
  EXPIRES_IN = 30.days

  def self.generate(user:, definition_id:, kind:)
    encryptor.encrypt_and_sign(
      { user_id: user.id, definition_id:, kind: },
      expires_in: EXPIRES_IN,
    )
  end

  def self.decode(token)
    encryptor.decrypt_and_verify(token)&.symbolize_keys
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil
  end

  def self.encryptor
    @encryptor ||= ActiveSupport::MessageEncryptor.new(
      Rails.application.key_generator.generate_key(
        'notification_unsubscribe', ActiveSupport::MessageEncryptor.key_len
      )
    )
  end
end
