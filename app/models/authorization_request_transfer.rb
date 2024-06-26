class AuthorizationRequestTransfer < ApplicationRecord
  belongs_to :authorization_request
  belongs_to :from,
    polymorphic: true
  belongs_to :to,
    polymorphic: true

  has_one :event,
    class_name: 'AuthorizationRequestEvent',
    inverse_of: :entity,
    dependent: :destroy

  has_one :initiator,
    through: :event,
    source: :user,
    class_name: 'User'

  validate :users_are_from_the_same_organization
  validate :entities_are_different
  validate :entities_are_same_type

  def entities_are_same_type
    return if from_type == to_type

    errors.add(:to, :different_type)
  end

  def users_are_from_the_same_organization
    return if from_type == 'Organization' || to_type == 'Organization'
    return if from.organization_ids.intersect?(to.organization_ids)

    errors.add(:to, :different_organization)
  end

  def entities_are_different
    return if from_id != to_id

    errors.add(:to, :different_user)
  end
end
