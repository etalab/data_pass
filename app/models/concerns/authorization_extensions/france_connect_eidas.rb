module AuthorizationExtensions::FranceConnectEidas
  extend ActiveSupport::Concern

  included do
    add_attribute :france_connect_eidas

    validates :france_connect_eidas,
      presence: true,
      inclusion: { in: %w[eidas_1 eidas_2] },
      if: -> { need_complete_validation?(:france_connect_eidas) }
  end
end
