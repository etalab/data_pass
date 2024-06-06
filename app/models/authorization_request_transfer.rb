class AuthorizationRequestTransfer < ApplicationRecord
  belongs_to :authorization_request
  belongs_to :from,
    class_name: 'User'
  belongs_to :to,
    class_name: 'User'

  has_one :event,
    class_name: 'AuthorizationRequestEvent',
    inverse_of: :entity,
    dependent: :destroy

  has_one :initiator,
    through: :event,
    source: :user,
    class_name: 'User'

  validate :users_are_from_the_same_organization
  validate :users_are_different

  def users_are_from_the_same_organization
    return if from.organization_ids.intersect?(to.organization_ids)

    errors.add(:to, :different_organization)
  end

  def users_are_different
    return if from_id != to_id

    errors.add(:to, :different_user)
  end
end
