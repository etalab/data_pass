class Authorization < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged

  validates :data, presence: true

  belongs_to :applicant,
    class_name: 'User',
    inverse_of: :authorizations_as_applicant

  belongs_to :request,
    class_name: 'AuthorizationRequest',
    inverse_of: :authorizations,
    dependent: :destroy

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
    -> { where(name: 'approve').order(created_at: :desc).limit(1) },
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
      transition from: :active, to: :obsolete
    end

    event :revoke do
      transition from: :active, to: :revoked
    end
  end

  # TODO : remove when the state machine is fully functional
  def revoked?
    if ENV.fetch('FEATURE_USE_AUTH_STATES', 'false') == 'true'
      self[:state] == 'revoked'
    else
      self[:revoked]
    end
  end

  # rubocop:disable Metrics/AbcSize
  def request_as_validated
    request_as_validated = authorization_request_class.constantize.new(request.dup.attributes.except('type'))

    request_as_validated.id = request.id
    request_as_validated.data = data
    request_as_validated.state = revoked? ? 'revoked' : 'validated'
    request_as_validated.created_at = created_at
    affect_snapshot_documents(request_as_validated)

    request_as_validated
  end
  # rubocop:enable Metrics/AbcSize

  def reopenable?
    latest?
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

  def reopenable_to_another_stage?
    authorization_request.latest_authorizations_of_each_stage.count > 1
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
