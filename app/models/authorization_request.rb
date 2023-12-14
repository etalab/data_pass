class AuthorizationRequest < ApplicationRecord
  store :data, coder: JSON

  belongs_to :applicant,
    class_name: 'User',
    inverse_of: :authorization_requests_as_applicant

  belongs_to :organization

  attr_accessor :current_build_step

  def form
    @form ||= AuthorizationRequestForm.where(authorization_request_class: self.class).first
  end

  def name
    data['intitule'] ||
      "#{form.name} n°#{id}"
  end

  def available_scopes
    form.scopes
  end

  validates :terms_of_service_accepted, presence: true, if: -> { need_complete_validation?(:finish) }
  validates :data_protection_officer_informed, presence: true, if: -> { need_complete_validation?(:finish) }

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
    names.each do |name|
      add_attribute(name)
    end
  end

  def self.add_attribute(name)
    class_eval do
      store_accessor :data, name

      extra_attributes.push(name)
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

  def self.contact(kind, validation_condition: nil)
    validation_condition ||= :need_complete_validation?

    class_eval do
      contact_attributes.each do |attr|
        store_accessor :data, "#{kind}_#{attr}"
        validates "#{kind}_#{attr}", presence: true, if: validation_condition
      end

      validates "#{kind}_email", format: { with: URI::MailTo::EMAIL_REGEXP }, if: validation_condition

      contact_types << kind
    end
  end

  def self.documents
    @documents ||= []
  end

  def self.add_document(name, validation_options = {})
    class_eval do
      has_one_attached name
      validates name, validation_options

      documents << name
    end
  end

  def self.scopes_enabled?
    @scopes_enabled
  end

  def self.add_scopes
    class_eval do
      store_accessor :data, :scopes

      @scopes_enabled = true
    end
  end

  def self.policy_class
    AuthorizationRequestPolicy
  end

  def need_complete_validation?(step = nil)
    if form.multiple_steps? && step != :finish
      %w[draft request_changes].exclude?(state) ||
        required_for_step?(step)
    else
      %w[draft request_changes].exclude?(state)
    end
  end

  # FIXME: not robust
  def required_for_step?(step)
    persisted? && (
      step.nil? ||
        current_build_step == 'finish' ||
        form.steps.pluck(:name).index(step.to_s) <= form.steps.pluck(:name).index(current_build_step)
    )
  end

  def applicant_belongs_to_organization
    return unless applicant.organizations.exclude?(organization)

    errors.add(:applicant, :belongs_to)
  end
end
