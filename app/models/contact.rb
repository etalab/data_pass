class Contact
  def initialize(contact_type, authorization_request)
    @contact_type = contact_type
    @authorization_request = authorization_request
  end

  def type
    @contact_type
  end

  %i[
    email
    given_name family_name
    phone_number job_title
  ].each do |contact_attribute|
    define_method contact_attribute do
      @authorization_request.data["#{@contact_type}_#{contact_attribute}"]
    end
  end
  alias job job_title

  def read_attribute_for_serialization(contact_attribute)
    public_send(contact_attribute)
  end
end
