class AuthorizationRequestChangelog < ApplicationRecord
  belongs_to :authorization_request

  has_one :organization, through: :authorization_request

  has_one :event,
    class_name: 'AuthorizationRequestEvent',
    inverse_of: :entity,
    dependent: :destroy

  def initial?
    authorization_request.events.where(name: 'submit').order(created_at: :asc).limit(1).first == event
  end
end
