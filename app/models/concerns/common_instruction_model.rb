module CommonInstructionModel
  extend ActiveSupport::Concern

  included do
    belongs_to :authorization_request

    has_one :event,
      class_name: 'AuthorizationRequestEvent',
      inverse_of: :entity,
      dependent: :destroy

    has_one :user,
      through: :event
  end
end
