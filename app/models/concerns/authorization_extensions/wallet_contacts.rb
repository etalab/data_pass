module AuthorizationExtensions::WalletContacts
  extend ActiveSupport::Concern

  CONTACT_TYPES = %i[wallet_application_manager wallet_technical_contact wallet_data_protection_officer].freeze
  APPLICANT_IDENTITY_ATTRIBUTES = %w[given_name family_name email].freeze
  NAME_ATTRIBUTES = %i[family_name given_name].freeze
  CONTACT_FIELDS = [*NAME_ATTRIBUTES, :email, :phone_number].freeze
  CONTACT_PHONE_FORMAT = /\A\+?(?:[\s.()-]*\d){10,}[\s.()-]*\z/
  WORD_CHARACTER = /[\p{L}\p{N}]/

  def self.contact_title(contact_type)
    I18n.t("authorization_request_forms.registre_wallet.#{contact_type}.title")
  end

  included do
    include AuthorizationCore::DraftFormats

    CONTACT_TYPES.each do |contact_type|
      contact contact_type,
        validation_condition: ->(record) { record.need_complete_validation?(:wallet_contacts) },
        options: { except: %w[job_title], email_format: false }

      contact_in_message = ->(_value) { { contact: AuthorizationExtensions::WalletContacts.contact_title(contact_type) } }

      NAME_ATTRIBUTES.each do |attribute|
        draft_format(:"#{contact_type}_#{attribute}", :blank) { |value| WORD_CHARACTER.match?(value) }
      end
      draft_format(:"#{contact_type}_email", :wallet_contact_email_format, options: contact_in_message) do |value|
        AuthorizationExtensions::WalletOrganization::EMAIL_FORMAT.match?(value)
      end
      draft_format(:"#{contact_type}_phone_number", :wallet_contact_phone_format, options: contact_in_message) do |value|
        CONTACT_PHONE_FORMAT.match?(value)
      end
    end
  end

  def wallet_contact_of_applicant(user)
    applicant_identity = APPLICANT_IDENTITY_ATTRIBUTES.map { |attribute| comparable(user.public_send(attribute)) }

    CONTACT_TYPES.find do |contact_type|
      contact_identity = APPLICANT_IDENTITY_ATTRIBUTES.map { |attribute| comparable(public_send(:"#{contact_type}_#{attribute}")) }

      contact_identity.all?(&:present?) && contact_identity == applicant_identity
    end
  end

  private

  def comparable(value)
    value.to_s.strip.downcase
  end
end
