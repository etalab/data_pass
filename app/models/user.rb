class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  before_save { email.downcase! }

  validates :external_id, presence: true, uniqueness: true

  has_and_belongs_to_many :organizations

  has_many :authorization_requests,
    dependent: :restrict_with_exception,
    inverse_of: :applicant

  def full_name
    "#{family_name} #{given_name}"
  end

  # rubocop:disable Metrics/AbcSize
  def self.find_or_create_from_mon_compte_pro(payload)
    info_payload = payload['info'].to_h

    user = User.where(external_id: payload['uid'], email: info_payload['email']).first_or_initialize

    user.assign_attributes(
      info_payload.slice(
        'family_name',
        'given_name',
        'email_verified'
      ).merge(
        'job_title' => info_payload['job']
      )
    )

    user.save!

    organization = Organization.find_or_create_from_mon_compte_pro(
      info_payload.slice(
        'siret',
        'label',
        'is_collectivite_territoriale',
        'is_commune',
        'is_external',
        'is_service_public',
      )
    )
    user.organizations << organization unless user.organizations.include?(organization)

    user
  end
  # rubocop:enable Metrics/AbcSize
end
