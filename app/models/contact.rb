class Contact
  def initialize(type, authorization_request)
    @type = type
    @authorization_request = authorization_request
  end

  attr_reader :type

  %i[
    email
    given_name
    family_name
    phone_number
    job_title
  ].each do |attribute|
    define_method attribute do
      @authorization_request.data["#{@type}_#{attribute}"]
    end
  end

  def read_attribute_for_serialization(attribute) = public_send(attribute)
end
