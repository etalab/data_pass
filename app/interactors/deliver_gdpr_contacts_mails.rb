class DeliverGDPRContactsMails < ApplicationInteractor
  def call
    gdpr_contacts.each do |gdpr_contact|
      notify(gdpr_contact) if email_defined?(gdpr_contact)
    end
  end

  private

  def gdpr_contacts
    AuthorizationExtensions::GDPRContacts::NAMES
  end

  def notify(gdpr_contact)
    GDPRContactMailer.with(params).public_send(gdpr_contact).deliver_later
  end

  def params
    {
      authorization_request: context.authorization_request
    }
  end

  def email_defined?(gdpr_contact)
    context.authorization_request.public_send(:"#{gdpr_contact}_email").present?
  rescue NoMethodError
    false
  end
end
