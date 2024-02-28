class GDPRContactMailer < ApplicationMailer
  AuthorizationExtensions::GDPRContacts::GDPR_CONTACTS.each do |contact|
    define_method(contact) do
      @authorization_request = params[:authorization_request]

      mail(
        to: @authorization_request.send(:"#{contact}_email"),
        subject: t(
          '.subject',
          authorization_request_contact_kind:
            t("authorization_request_forms.default.#{contact}.title").downcase,
          authorization_request_name: @authorization_request.name
        )
      )
    end
  end
end
