class Authorization < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, use: :scoped, scope: :request

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

  scope :validated, -> { joins(:request).where(authorization_requests: { state: 'validated' }) }

  delegate :name, :kind, to: :request

  before_create do
    self[:authorization_request_class] ||= request.type
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

  def latest?
    request.latest_authorization == self
  end

  def latest
    request.latest_authorization
  end

  def authorization_request
    request
  end

  private

  def affect_snapshot_documents(request_as_validated)
    request_as_validated.class.documents.each do |document|
      snapshoted_document = documents.find_by(identifier: document)
      next if snapshoted_document.nil?

      request_as_validated.public_send(:"#{document}=", snapshoted_document.file.blob)
    end
  end

  def slug_candidates
    [
      :slug_created_at_as_date,
      -> { "#{slug_created_at_as_date}--1" },
      -> { "#{slug_created_at_as_date}--2" },
      -> { "#{slug_created_at_as_date}--3" },
    ]
  end

  def slug_created_at_as_date
    (created_at || Date.current).strftime('%d-%m-%Y')
  end
end
