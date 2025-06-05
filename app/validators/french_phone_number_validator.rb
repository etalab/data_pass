class FrenchPhoneNumberValidator < ActiveModel::EachValidator
  FRENCH_PHONE_FORMATS = [
    /\A0[1-9]([\s\.\-]*\d{2}){4}\z/, # 0[1-9] XX XX XX XX (with spaces, dots, or dashes)
    /\A\+33[\s\.\-]*[1-9]([\s\.\-]*\d{2}){4}\z/ # +33 [1-9] XX XX XX XX (with spaces, dots, or dashes)
  ].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    return if valid_french_phone_number?(value)

    record.errors.add(attribute, :invalid_french_phone_format)
  end

  private

  def valid_french_phone_number?(phone_number)
    FRENCH_PHONE_FORMATS.any? { |format| format.match?(phone_number) }
  end
end
