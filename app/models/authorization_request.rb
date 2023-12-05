class AuthorizationRequest < ApplicationRecord
  store :data, coder: JSON

  belongs_to :applicant,
    class_name: 'User',
    inverse_of: :authorization_requests

  belongs_to :organization

  def form_model
    @form_model ||= AuthorizationRequestForm.where(authorization_request_class: self.class).first
  end

  state_machine initial: :draft do
    state :draft
    state :submitted

    event :submit do
      transition from: %i[draft], to: :submitted
    end
  end

  validate :applicant_belongs_to_organization

  def self.extra_attributes
    @extra_attributes ||= []
  end

  def self.add_attributes(*names)
    class_eval do
      names.each do |name|
        store_accessor :data, name
      end

      extra_attributes.concat(names)
    end
  end

  def self.contact_types
    @contact_types ||= []
  end

  def self.contact_attributes
    %w[
      family_name
      given_name
      email
      phone_number
      job_title
    ]
  end

  def self.contact(kind)
    class_eval do
      contact_attributes.each do |attr|
        store_accessor :data, "#{kind}_#{attr}"
        validates "#{kind}_#{attr}", presence: true, if: :need_complete_validation?
      end

      validates "#{kind}_email", format: { with: URI::MailTo::EMAIL_REGEXP }, if: :need_complete_validation?

      contact_types << kind
    end
  end

  def need_complete_validation?
    %w[draft request_changes].exclude?(state)
  end

  def applicant_belongs_to_organization
    return unless applicant.organizations.exclude?(organization)

    errors.add(:applicant, :belongs_to)
  end
end
