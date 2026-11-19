RSpec.describe AuthorizationCore::Contacts do
  def request_class_with_contact(options = {})
    Class.new(AuthorizationRequest) do
      def self.name
        'AuthorizationRequest::ContactsSpecDummy'
      end

      contact :contact_spec, validation_condition: ->(_record) { true }, options:
    end
  end

  def email_errors_for(request_class, email)
    request = request_class.new(contact_spec_email: email)
    request.validate

    request.errors.where(:contact_spec_email).map(&:type)
  end

  it 'checks the email format by default' do
    expect(email_errors_for(request_class_with_contact, 'camille.martin@')).to include(:invalid)
  end

  it 'leaves the email format to the form when email_format is false' do
    expect(email_errors_for(request_class_with_contact(email_format: false), 'camille.martin@')).not_to include(:invalid)
  end

  it 'still requires the email when email_format is false' do
    expect(email_errors_for(request_class_with_contact(email_format: false), '')).to include(:blank)
  end

  it 'lists the errors of a contact in the order of the form fields' do
    request = request_class_with_contact.new
    request.validate

    contact_errors = request.errors.attribute_names.grep(/\Acontact_spec_/).map { |attribute| attribute.to_s.delete_prefix('contact_spec_') }

    expect(contact_errors).to eq(%w[family_name given_name email phone_number job_title])
  end
end
