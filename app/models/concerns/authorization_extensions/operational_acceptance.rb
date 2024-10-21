module AuthorizationExtensions::OperationalAcceptance
  extend ActiveSupport::Concern

  included do
    add_attribute :operational_acceptance_done

    validates :operational_acceptance_done,
      acceptance: true,
      if: -> { need_complete_validation?(:operational_acceptance) }
  end
end
