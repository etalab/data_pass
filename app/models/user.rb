class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  before_save { email.downcase! }

  validates :external_id, presence: true, uniqueness: true

  has_and_belongs_to_many :organizations

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

    info_payload['organizations'].each do |organization_payload|
      organization = Organization.find_or_create_from_mon_compte_pro(organization_payload)
      user.organizations << organization unless user.organizations.include?(organization)
    end

    user
  end
  # rubocop:enable Metrics/AbcSize
end
