class GDPRContactMailerPreview < ActionMailer::Preview
  AuthorizationExtensions::GDPRContacts::NAMES.each do |contact|
    define_method contact do
      GDPRContactMailer.with(params_for(contact)).send(contact)
    end
  end

  private

  def params_for(contact)
    {
      authorization_request: find_authorization_request_by(contact)
    }
  end

  def find_authorization_request_by(contact)
    AuthorizationRequest.where("data ? '#{contact}_email'").first
  end
end
