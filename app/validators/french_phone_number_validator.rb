class FrenchPhoneNumberValidator < ActiveModel::EachValidator
  FRENCH_PHONE_FORMATS = [
    /\A0[1-9]([\s.-]*\d{2}){4}\z/, # 0[1-9] XX XX XX XX (with spaces, dots, or dashes)
    /\A\+33[\s.-]*[1-9]([\s.-]*\d{2}){4}\z/, # +33 [1-9] XX XX XX XX (with spaces, dots, or dashes)
    /\A\+590[\s.-]*[1-9]([\s.-]*\d{2}){4}\z/, # +590 (Guadeloupe, Saint-Martin, Saint-Barthélemy)
    /\A\+594[\s.-]*[1-9]([\s.-]*\d{2}){4}\z/, # +594 (French Guiana)
    /\A\+596[\s.-]*[1-9]([\s.-]*\d{2}){4}\z/, # +596 (Martinique)
    /\A\+687[\s.-]*\d{2}([\s.-]*\d{2}){2}\z/ # +687 (New Caledonia - 6 digits format)
  ].freeze

  MOBIL_PHONE_FORMATS = [
    # Métropole
    /\A0[67]([\s.-]*\d{2}){4}\z/, # 06 XX XX XX XX ou 07 XX XX XX XX (avec espaces, points ou tirets)
    /\A\+33[\s.-]*[67]([\s.-]*\d{2}){4}\z/, # +33 6 XX XX XX XX ou +33 7 XX XX XX XX

    # DOM-TOM
    /\A\+590[\s.-]*[67]([\s.-]*\d{2}){4}\z/, # Guadeloupe, Saint-Martin, Saint-Barthélemy
    /\A\+594[\s.-]*[67]([\s.-]*\d{2}){4}\z/, # Guyane française
    /\A\+596[\s.-]*[67]([\s.-]*\d{2}){4}\z/, # Martinique
    /\A\+687[\s.-]*\d{2}([\s.-]*\d{2}){2}\z/, # Nouvelle-Calédonie (format 6 chiffres)
    /\A\+689[\s.-]*\d{2}([\s.-]*\d{2}){2}\z/  # Polynésie française (format 6 chiffres)
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
