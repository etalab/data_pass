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

  has_many :instructor_modification_requests,
    class_name: 'InstructorModificationRequest',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_one :denial,
    -> { order(created_at: :desc) },
    class_name: 'DenialOfAuthorization',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_many :revocations,
    class_name: 'RevocationOfAuthorization',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_one :revocation,
    -> { order(created_at: :desc) },
    class_name: 'RevocationOfAuthorization',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_many :changelogs,
    class_name: 'AuthorizationRequestChangelog',
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

  has_many :transfers,
    class_name: 'AuthorizationRequestTransfer',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_many :reopening_cancellations,
    class_name: 'AuthorizationRequestReopeningCancellation',
    inverse_of: :request,
    dependent: :destroy

  has_many :authorizations,
    class_name: 'Authorization',
    inverse_of: :request,
    dependent: :destroy

  has_many :messages,
    dependent: :destroy

  has_many :events,
    class_name: 'AuthorizationRequestEvent',
    inverse_of: :entity,
    dependent: :destroy

  has_one :copied_from_request,
    inverse_of: :next_request_copied,
    class_name: 'AuthorizationRequest',
    dependent: :nullify

  belongs_to :next_request_copied,
    class_name: 'AuthorizationRequest',
    inverse_of: :copied_from_request,
    optional: true

  def latest_authorization
    authorizations.order(created_at: :desc).limit(1).first
  end

  def events
    @events ||= AuthorizationRequestEventsQuery.new(self).perform
  end

  scope :drafts, -> { where(state: 'draft') }
  scope :changes_requested, -> { where(state: 'changes_requested') }
  scope :in_instructions, -> { where(state: 'submitted') }
  scope :validated, -> { where(state: 'validated') }
  scope :refused, -> { where(state: 'refused') }
  scope :validated_or_refused, -> { where('state in (?) or last_validated_at is not null', %w[validated refused]) }
  scope :not_archived, -> { where.not(state: 'archived') }
  scope :without_reopening, -> { where(last_validated_at: nil) }
  scope :revoked, -> { where(state: 'revoked') }

  validates :form_uid, presence: true
  validate :applicant_belongs_to_organization

  class << self
    delegate :description, :available_forms, :provider, :startable_by_applicant, to: :definition

    def definition
      @definition ||= AuthorizationDefinition.find(to_s.demodulize.underscore)
    end
  end

  def class_name
    self.class.name
  end

  def kind
    type.underscore.split('/').last
  end

  def definition
    self.class.definition
  end

  def form
    @form ||= AuthorizationRequestForm.find(form_uid)
  end

  def name
    data['intitule'].presence ||
      definition.name.to_s
  end

  with_options on: :submit do
    validate :all_terms_accepted
  end

  def all_terms_accepted
    return if terms_of_service_accepted && data_protection_officer_informed

    errors.add(:base, :all_terms_not_accepted)
  end

  # rubocop:disable Metrics/BlockLength
  state_machine initial: :draft do
    state :draft
    state :submitted
    state :changes_requested
    state :validated
    state :refused
    state :archived
    state :revoked

    event :submit do
      transition from: %i[draft changes_requested], to: :submitted, unless: ->(authorization_request) { authorization_request.reopening? }
      transition from: %i[draft changes_requested refused], to: :submitted, if: ->(authorization_request) { authorization_request.reopening? }
    end

    event :refuse do
      transition from: %i[changes_requested submitted], to: :refused, unless: ->(authorization_request) { authorization_request.reopening? }
      transition from: %i[changes_requested submitted], to: :validated, if: ->(authorization_request) { authorization_request.reopening? }
    end

    event :request_changes do
      transition from: :submitted, to: :changes_requested
    end

    event :approve do
      transition from: :submitted, to: :validated
    end

    after_transition to: :submitted do |authorization_request|
      authorization_request.update(last_submitted_at: Time.zone.now)
    end

    after_transition to: :validated do |authorization_request|
      authorization_request.update(last_validated_at: Time.zone.now)
    end

    event :archive do
      transition from: all - %i[archived validated], to: :archived, unless: ->(authorization_request) { authorization_request.reopening? }
    end

    event :reopen do
      transition from: :validated, to: :draft, if: ->(authorization_request) { authorization_request.reopenable? }
    end

    event :cancel_reopening do
      transition from: %i[draft changes_requested submitted], to: :validated, if: ->(authorization_request) { authorization_request.reopening? }
    end

    event :revoke do
      transition from: :validated, to: :revoked
    end
  end
  # rubocop:enable Metrics/BlockLength

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      type
      within_data
      state
      last_submitted_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      applicant
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
    return false if archived?
    return false if static_data_already_filled?(step)

    if form.multiple_steps?
      !filling? ||
        required_for_step?(step)
    else
      !filling?
    end
  end

  kredis_counter :redis_unread_messages_from_applicant
  kredis_counter :redis_unread_messages_from_instructors

  def unread_messages_from_applicant_count
    redis_unread_messages_from_applicant.value
  end

  def unread_messages_from_instructors_count
    redis_unread_messages_from_instructors.value
  end

  # rubocop:disable Rails/SkipsModelValidations
  def mark_messages_as_read_by_applicant!
    redis_unread_messages_from_applicant.reset
    messages.from_users(definition.instructors).unread.update_all(read_at: DateTime.current)
  end

  def mark_messages_as_read_by_instructors!
    redis_unread_messages_from_instructors.reset
    messages.from_users(applicant).unread.update_all(read_at: DateTime.current)
  end
  # rubocop:enable Rails/SkipsModelValidations

  def static_data_already_filled?(step)
    form.static_blocks.pluck(:name).include?(step.to_s)
  end

  attr_writer :current_build_step

  def current_build_step
    return unless form.multiple_steps? && steps_names.include?(@current_build_step)

    @current_build_step
  end

  def required_for_step?(step)
    return false if validation_context == :save_within_wizard
    return false if current_build_step.blank?

    step.nil? ||
      steps_names.index(step.to_s) <= steps_names.index(current_build_step)
  end

  def steps_names
    @steps_names ||= form.steps.pluck(:name)
  end

  def filling?
    %w[draft changes_requested].include?(state)
  end

  def finished?
    %w[validated refused].include?(state)
  end

  def already_been_validated?
    last_validated_at.present?
  end

  delegate :reopenable?, to: :definition

  def reopening?
    %w[validated revoked].exclude?(state) &&
      last_validated_at.present?
  end

  def changed_since_authorization?
    data != latest_authorization&.data
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

  def access_link
    return nil if definition.access_link.blank? || external_provider_id.blank?

    format(definition.access_link, external_provider_id:)
  end
end
