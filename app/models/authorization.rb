class Authorization < ApplicationRecord
  extend FriendlyId
  include DemandesHabilitationsSearchable

  friendly_id :slug_candidates, use: :slugged

  validates :data, presence: true

  belongs_to :applicant,
    class_name: 'User',
    inverse_of: :authorizations_as_applicant

  belongs_to :request,
    class_name: 'AuthorizationRequest',
    inverse_of: :authorizations

  has_one :organization,
    through: :request

  has_many :documents,
    class_name: 'AuthorizationDocument',
    inverse_of: :authorization,
    dependent: :destroy

  has_many :authorization_request_events,
    as: :entity,
    dependent: :nullify

  has_one :approve_authorization_request_event,
    -> { where(name: 'approve').order(created_at: :desc) },
    dependent: :nullify,
    class_name: 'AuthorizationRequestEvent',
    inverse_of: :entity

  has_one :approving_instructor,
    through: :approve_authorization_request_event,
    source: :user

  scope :validated, -> { where(revoked: false) }

  delegate :name, :kind, to: :request

  before_create do
    self[:authorization_request_class] ||= request.type
  end

  state_machine initial: :active do
    state :active
    state :obsolete
    state :revoked

    event :deprecate do
      transition from: %i[active obsolete], to: :obsolete
    end

    event :revoke do
      transition from: :active, to: :revoked
      transition from: :obsolete, to: :obsolete
    end

    event :rollback_revoke do
      transition from: :revoked, to: :active
      transition from: :obsolete, to: :obsolete
    end
  end

  def self.model_specific_ransackable_attributes
    %w[
      authorization_request_class
      request_id
      revoked
      slug
      state
      user_relationship_eq
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    authorizable_ransackable_associations + %w[
      request
    ]
  end

  def access_link
    return nil if definition.access_link.blank? || request.external_provider_id.blank?

    format(definition.access_link, external_provider_id: request.external_provider_id)
  end

  # rubocop:disable Metrics/AbcSize
  def request_as_validated(load_documents: true)
    request_as_validated = authorization_request_class.constantize.new(request.dup.attributes.except('type'))

    request_as_validated.id = request.id
    request_as_validated.data = data
    request_as_validated.applicant_id = applicant_id
    request_as_validated.state = revoked? ? 'revoked' : 'validated'
    request_as_validated.created_at = created_at
    affect_snapshot_documents(request_as_validated) if load_documents

    request_as_validated
  end
  # rubocop:enable Metrics/AbcSize

  def reopenable?
    if multi_stage? && stage.type == 'production'
      common_reopenable? &&
        request.latest_authorization.stage.type != 'sandbox'
    else
      common_reopenable?
    end
  end

  def common_reopenable?
    latest? &&
      !request.currently_reopen? &&
      active? &&
      !request.dirty_from_v1?
  end

  def latest?
    if definition.stage.exists?
      request.latest_authorization_of_class(authorization_request_class) == self
    else
      request.latest_authorization == self
    end
  end

  def latest
    request.latest_authorization
  end

  def authorization_request
    request
  end

  def definition
    authorization_request_class.constantize.definition
  end

  delegate :multi_stage?, to: :definition

  def reopenable_to_another_stage?
    latest_authorizations_of_each_stage = authorization_request.latest_authorizations_of_each_stage

    latest_authorizations_of_each_stage.many? &&
      latest_authorizations_of_each_stage.all?(&:reopenable?)
  end

  def stage
    return unless multi_stage?

    authorization_request_class.constantize.definition.stage
  end

  def contact_types_for(user)
    contact_type_key_values = data.select do |key, value|
      key =~ /.*_email$/ && value == user.email
    end

    contact_type_key_values.keys.map do |key|
      key.match(/^(.*)_email$/)[1]
    end
  end

  private

  def affect_snapshot_documents(request_as_validated)
    request_as_validated.class.documents.each do |document|
      snapshoted_document = documents.find_by(identifier: document.name)
      next if snapshoted_document.nil?

      Array(snapshoted_document.files).each do |file|
        request_as_validated.public_send(:"#{document.name}").attach(file.blob)
      end
    end
  end

  def slug_candidates
    [
      :authorization_request_id_with_date,
      -> { "#{authorization_request_id_with_date}--1" },
      -> { "#{authorization_request_id_with_date}--2" },
      -> { "#{authorization_request_id_with_date}--3" },
    ]
  end

  def authorization_request_id_with_date
    "#{request.id}--#{(created_at || Date.current).strftime('%d-%m-%Y')}"
  end
end
