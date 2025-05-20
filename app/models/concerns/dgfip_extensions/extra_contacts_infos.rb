module DGFIPExtensions::ExtraContactsInfos
  extend ActiveSupport::Concern

  included do
    add_attribute :extra_organization_contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }
    add_attribute :contact_technique_extra_email, format: { with: URI::MailTo::EMAIL_REGEXP }
    add_attribute :extra_organization_contact_name
  end
end
