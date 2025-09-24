class AuthorizationRequest < ApplicationRecord
  self.ignored_columns += %w[reopening next_request_copied_id]

  include AuthorizationCore::Attributes
  include AuthorizationCore::Documents
  include AuthorizationCore::Contacts
  include AuthorizationCore::Scopes
  include AuthorizationCore::Checkboxes
  include DemandesHabilitationsSearchable

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

  has_many :active_authorizations,
    -> { where(state: 'active') },
    class_name: 'Authorization',
    inverse_of: :request,
    dependent: :destroy

  has_many :messages,
    dependent: :destroy

  has_many :events_without_bulk_update,
    class_name: 'AuthorizationRequestEvent',
    inverse_of: :authorization_request,
    dependent: :destroy

  belongs_to :copied_from_request,
    inverse_of: :copies,
    class_name: 'AuthorizationRequest',
    optional: true

  has_many :copies,
    class_name: 'AuthorizationRequest',
    foreign_key: :copied_from_request_id,
    inverse_of: :copied_from_request,
    dependent: :nullify

  def latest_authorization
    authorizations.order(created_at: :desc).limit(1).first
  end

  def latest_authorizations_of_each_stage
    authorizations.group_by(&:authorization_request_class).map do |_, authorizations|
      authorizations.max_by(&:created_at)
    end
  end

  def latest_authorization_of_stage(stage_type)
    return unless definition.multi_stage?

    authorizations.where(authorization_request_class: extract_authorization_request_class_from_stage(stage_type)).order(created_at: :desc).limit(1).first
  end

  def latest_authorization_of_class(authorization_request_class)
    authorizations.where(authorization_request_class:).order(created_at: :desc).limit(1).first
  end

  def events
    @events ||= AuthorizationRequestEventsQuery.new(self).perform
  end

  def bulk_updates
    @bulk_updates ||= BulkAuthorizationRequestUpdate.where(authorization_definition_uid: definition.id, application_date: (created_at.to_date..)).order(:created_at)
  end

  def latest_bulk_update
    bulk_updates.order(application_date: :desc).limit(1).first
  end

  scope :drafts, -> { where(state: 'draft') }
  scope :changes_requested, -> { where(state: 'changes_requested') }
  scope :in_instructions, -> { where(state: 'submitted') }
  scope :validated, -> { where(state: 'validated') }
  scope :refused, -> { where(state: 'refused') }
  scope :validated_or_refused, -> { where('authorization_requests.state in (?) or last_validated_at is not null', %w[validated refused]) }
  scope :not_archived, -> { where.not(state: 'archived') }
  scope :not_validated, -> { where.not(state: 'validated') }
  scope :without_reopening, -> { where(last_validated_at: nil) }
  scope :revoked, -> { where(state: 'revoked') }
  scope :active, -> { where.not(state: %w[revoked refused archived]) }

  validates :form_uid, presence: true
  validate :applicant_belongs_to_organization

  class << self
    delegate :description, :available_forms, :provider, :startable_by_applicant, to: :definition

    def definition
      @definition ||= AuthorizationDefinition.find(to_s.demodulize.underscore)
    end
  end

  delegate :name, to: :class, prefix: true

  def kind
    type.underscore.split('/').last
  end

  delegate :definition, to: :class

  def form
    @form ||= AuthorizationRequestForm.find(form_uid)
  end

  delegate :service_provider, to: :form

  def name
    data['intitule'].presence ||
      form.name ||
      definition.name
  end

  with_options on: :submit do
    validate :all_terms_accepted
  end

  def skip_data_protection_officer_informed_check_box?
    self.class.contacts.none? { |c| c.type == :delegue_protection_donnees }
  end

  def all_terms_accepted
    return if terms_of_service_accepted && (skip_data_protection_officer_informed_check_box? || data_protection_officer_informed) && all_extra_checkboxes_checked?

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

    after_transition to: :submitted do |authorization_request|
      authorization_request.update(last_submitted_at: Time.zone.now)
    end

    event :refuse do
      transition from: %i[changes_requested submitted], to: :refused, unless: ->(authorization_request) { authorization_request.reopening? }
      transition from: %i[changes_requested submitted], to: :validated, if: ->(authorization_request) { authorization_request.reopening? }
    end

    event :request_changes do
      transition from: :submitted, to: :changes_requested
    end

    event :approve do
      transition from: %i[changes_requested submitted], to: :validated
    end

    after_transition to: :validated do |authorization_request|
      authorization_request.update(last_validated_at: Time.zone.now)
    end

    event :archive do
      transition from: all - %i[submitted changes_requested archived validated], to: :archived, unless: ->(authorization_request) { authorization_request.active_authorizations.any? }
    end

    event :reopen do
      transition from: :validated, to: :draft, if: ->(authorization_request) { authorization_request.reopenable? }
    end

    after_transition on: :reopen do |authorization_request|
      authorization_request.update(reopened_at: Time.zone.now)
    end

    event :cancel_reopening do
      transition from: %i[draft changes_requested submitted], to: :validated, if: ->(authorization_request) { authorization_request.reopening? }
    end

    event :start_next_stage do
      transition from: :validated, to: :draft, if: ->(authorization_request) { authorization_request.definition.next_stage? }
    end

    after_transition on: :start_next_stage do |authorization_request|
      authorization_request.update!(
        type: authorization_request.definition.next_stage_definition.authorization_request_class,
        form_uid: authorization_request.definition.next_stage_form.id,
        terms_of_service_accepted: false,
        data_protection_officer_informed: false,
      )
    end

    event :cancel_next_stage do
      transition from: %i[draft changes_requested submitted], to: :validated, if: ->(authorization_request) { authorization_request.definition.previous_stage? }
    end

    event :revoke do
      transition from: :validated, to: :revoked
    end
  end
  # rubocop:enable Metrics/BlockLength

  def self.model_specific_ransackable_attributes
    %w[
      type
      state
      last_submitted_at
      user_id
      user_relationship
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    authorizable_ransackable_associations + %w[
      authorizations
    ]
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
    return false if steps_names.exclude?(step.to_s)

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

  def reopening?
    if multi_stage?
      authorizations.any? { |a| a.authorization_request_class == type }
    else
      last_validated_at.present? && reopened_at.present?
    end &&
      %w[validated revoked].exclude?(state)
  end

  def reopenable?
    authorizations.any?(&:reopenable?)
  end

  delegate :multi_stage?, to: :definition

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

  def with_france_connect?
    false
  end

  def access_link
    return nil if definition.access_link.blank? || external_provider_id.blank?

    format(definition.access_link, external_provider_id:)
  end

  def any_next_stage_authorization_exists?
    return false unless definition.multi_stage?
    return false unless definition.next_stage?

    latest_authorization_of_class(definition.next_stage_definition.authorization_request_class.to_s).present?
  end

  private

  def extract_authorization_request_class_from_stage(stage_type)
    if stage_type == definition.stage.type
      definition.authorization_request_class_as_string
    else
      definition.stage.previous_stage[:definition].authorization_request_class_as_string
    end
  end
end
