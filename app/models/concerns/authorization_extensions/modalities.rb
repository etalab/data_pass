module AuthorizationExtensions::Modalities
  extend ActiveSupport::Concern

  included do
    add_attributes :modalities
    add_attributes :france_connect_authorization_id
    validates :modalities, presence: true, if: -> { need_complete_validation?(:modalities) }
  end

  def available_modalities
    self.class::MODALITIES
  rescue NameError
    raise "Must declare a constant MODALITIES in the model #{self.class}, for example %w[with_france_connect with_spi]"
  end
end
