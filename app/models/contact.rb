class Contact
  ATTRIBUTES = %i[
    email
    given_name
    family_name
    phone_number
    job_title
  ].freeze

  def initialize(type, authorization_request)
    @type = type
    @authorization_request = authorization_request
  end

  attr_reader :type

  ATTRIBUTES.each do |attribute|
    define_method attribute do
      @authorization_request.data["#{@type}_#{attribute}"]
    end
  end

  def to_attributes(prefix: nil)
    ATTRIBUTES.each_with_object({}) do |attribute, hash|
      key = prefix ? "#{prefix}_#{attribute}" : attribute
      value = public_send(attribute)
      hash[key.to_sym] = value if value.present?
    end
  end
end
