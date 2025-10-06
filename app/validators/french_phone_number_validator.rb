class FrenchPhoneNumberValidator < ActiveModel::EachValidator
  FRENCH_PHONE_FORMATS = [
    /\A0[1-9]([\s.-]*\d{2}){4}\z/, # 0[1-9] XX XX XX XX (with spaces, dots, or dashes)
    /\A\+33[\s.-]*[1-9]([\s.-]*\d{2}){4}\z/, # +33 [1-9] XX XX XX XX (with spaces, dots, or dashes)
    /\A\+590[\s.-]*[1-9]([\s.-]*\d{2}){4}\z/, # +590 (Guadeloupe, Saint-Martin, Saint-Barthélemy)
    /\A\+594[\s.-]*[1-9]([\s.-]*\d{2}){4}\z/, # +594 (French Guiana)
    /\A\+596[\s.-]*[1-9]([\s.-]*\d{2}){4}\z/, # +596 (Martinique)
    /\A\+262[\s.-]*\d{2}([\s.-]*\d{2}){3}\z/, # +262 (Réunion, Mayotte - 8 digits format)
    /\A\+508[\s.-]*\d{2}([\s.-]*\d{2}){2}\z/, # +508 (Saint-Pierre-et-Miquelon - 6 digits format)
    /\A\+681[\s.-]*\d{2}([\s.-]*\d{2}){2}\z/, # +681 (Wallis-et-Futuna - 6 digits format)
    /\A\+687[\s.-]*\d{2}([\s.-]*\d{2}){2}\z/, # +687 (New Caledonia - 6 digits format)
    /\A\+689[\s.-]*4[0-9]([\s.-]*\d{2}){2}\z/, # +689 (French Polynesia landlines - 4[0-9] XX XX)
    /\A\+689[\s.-]*8[79]([\s.-]*\d{2}){2}\z/, # +689 (French Polynesia mobiles - 87/89 XX XX)
  ].freeze

  MOBIL_PHONE_FORMATS = [
    # Métropole
    /\A0[67]([\s.-]*\d{2}){4}\z/, # 06 XX XX XX XX ou 07 XX XX XX XX (avec espaces, points ou tirets)
    /\A\+33[\s.-]*[67]([\s.-]*\d{2}){4}\z/, # +33 6 XX XX XX XX ou +33 7 XX XX XX XX

    # DOM-TOM
    /\A\+590[\s.-]*[67]([\s.-]*\d{2}){4}\z/, # Guadeloupe, Saint-Martin, Saint-Barthélemy
    /\A\+594[\s.-]*[67]([\s.-]*\d{2}){4}\z/, # Guyane française
    /\A\+596[\s.-]*[67]([\s.-]*\d{2}){4}\z/, # Martinique
    /\A\+262[\s.-]*[67]([\s.-]*\d{2}){3}\z/, # Réunion, Mayotte (8 digits)
    /\A\+508[\s.-]*7\d([\s.-]*\d{2}){2}\z/, # Saint-Pierre-et-Miquelon mobile (7X XX XX)
    /\A\+681[\s.-]*\d{2}([\s.-]*\d{2}){2}\z/, # Wallis-et-Futuna
    /\A\+687[\s.-]*\d{2}([\s.-]*\d{2}){2}\z/, # Nouvelle-Calédonie (format 6 chiffres)
    /\A\+689[\s.-]*8[79]([\s.-]*\d{2}){2}\z/  # Polynésie française (format 6 chiffres)
  ].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    valid = if options[:france_connect_mobile]
              valid_mobile_phone_number?(value)
            else
              valid_french_phone_number?(value)
            end

    return if valid

    if options[:france_connect_mobile]
      record.errors.add(attribute, :france_connect_mobile_phone_message)
    else
      record.errors.add(attribute, :invalid_french_phone_format)
    end
  end

  private

  def valid_french_phone_number?(phone_number)
    FRENCH_PHONE_FORMATS.any? { |format| format.match?(phone_number) }
  end

  def valid_mobile_phone_number?(phone_number)
    MOBIL_PHONE_FORMATS.any? { |format| format.match?(phone_number) }
  end
end
