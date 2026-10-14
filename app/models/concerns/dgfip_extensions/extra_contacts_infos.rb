module DGFIPExtensions::ExtraContactsInfos
  extend ActiveSupport::Concern

  included do
    add_attribute :extra_organization_contact_email
    add_attribute :contact_technique_extra_email
    add_attribute :extra_organization_contact_name

    validates :extra_organization_contact_email, :contact_technique_extra_email,
      format: { with: URI::MailTo::EMAIL_REGEXP },
      allow_blank: true,
      if: -> { need_complete_validation?(:contacts) }
  end
end
