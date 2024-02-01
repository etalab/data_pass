class AuthorizationRequest < ApplicationRecord
  include AuthorizationCore::Attributes
  include AuthorizationCore::Documents
  include AuthorizationCore::Contacts
  include AuthorizationCore::Scopes

  belongs_to :applicant,
    class_name: 'User',
    inverse_of: :authorization_requests_as_applicant

  belongs_to :organization

  has_many :denials,
    class_name: 'DenialOfAuthorization',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_one :denial,
    -> { order(created_at: :desc) },
    class_name: 'DenialOfAuthorization',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_many :modification_requests,
    class_name: 'InstructorModificationRequest',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_one :modification_request,
    -> { order(created_at: :desc) },
    class_name: 'InstructorModificationRequest',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_many :authorizations,
    class_name: 'Authorization',
    inverse_of: :authorization_request,
    dependent: :nullify

  has_one :latest_authorization,
    -> { order(created_at: :desc).limit(1) },
    class_name: 'Authorization',
    inverse_of: :authorization_request,
    dependent: :nullify

  def events
    @events ||= AuthorizationRequestEventsQuery.new(self).perform
  end

  scope :drafts, -> { where(state: 'draft') }
  scope :changes_requested, -> { where(state: 'changes_requested') }
  scope :in_instructions, -> { where(state: 'submitted') }
  scope :validated, -> { where(state: 'validated') }
  scope :refused, -> { where(state: 'refused') }
  scope :validated_or_refused, -> { where(state: %w[validated refused]) }

  validates :form_uid, presence: true

  class << self
    delegate :description, :available_forms, :provider, :startable_by_applicant, :unique?, to: :definition

    def definition
      @definition ||= AuthorizationDefinition.find(to_s.demodulize.underscore)
    end
  end

  def definition
    self.class.definition
  end

  def form
    @form ||= AuthorizationRequestForm.find(form_uid)
  end

  def name
    data['intitule'] ||
      "#{definition.name} n°#{id}"
  end

  with_options on: :submit do
    validates :terms_of_service_accepted, presence: true, inclusion: [true]
    validates :data_protection_officer_informed, presence: true, inclusion: [true]
  end

  state_machine initial: :draft do
    state :draft
    state :submitted
    state :changes_requested
    state :validated
    state :refused
    state :archived
    state :revoked

    event :submit do
      transition from: %i[draft changes_requested], to: :submitted
    end

    event :refuse do
      transition from: %i[changes_requested submitted], to: :refused
    end

    event :request_changes do
      transition from: :submitted, to: :changes_requested
    end

    event :approve do
      transition from: :submitted, to: :validated
    end
  end

  validate :applicant_belongs_to_organization

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      type
      within_data
      state
      created_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      organization
    ]
  end

  ransacker :within_data do |_parent|
    Arel.sql('authorization_requests.data::text')
  end

  def self.policy_class
    AuthorizationRequestPolicy
  end

  def need_complete_validation?(step = nil)
    return true if %i[submit review].include?(validation_context)

    if form.multiple_steps?
      raise "Unknown step #{step}" if step.present? && steps_names.exclude?(step.to_s)

      !in_draft_or_archived? ||
        required_for_step?(step)
    else
      !in_draft_or_archived?
    end
  end

  attr_writer :current_build_step

  def current_build_step
    if form.multiple_steps? && steps_names.include?(@current_build_step)
      @current_build_step
    else
      form.steps.last[:name]
    end
  end

  def required_for_step?(step)
    persisted? && (
      step.nil? ||
        steps_names.index(step.to_s) <= steps_names.index(current_build_step)
    )
  end

  def steps_names
    @steps_names ||= form.steps.pluck(:name)
  end

  def in_draft?
    %w[draft changes_requested].include?(state)
  end

  def in_draft_or_archived?
    in_draft? || state == 'archived'
  end

  def finished?
    %w[validated refused].include?(state)
  end

  def contact_types_for(user)
    contact_type_key_values = data.select do |key, value|
      key =~ /.*_email$/ && value == user.email
    end

    contact_type_key_values.keys.map do |key|
      key.match(/^(.*)_email$/)[1]
    end
  end

  def applicant_belongs_to_organization
    return if organization.blank? || applicant.blank?
    return unless applicant.organizations.exclude?(organization)

    errors.add(:applicant, :belongs_to)
  end
end
