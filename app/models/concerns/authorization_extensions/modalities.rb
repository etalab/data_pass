module AuthorizationExtensions::Modalities
  extend ActiveSupport::Concern

  included do
    add_attributes :modalities
    add_attributes :france_connect_authorization_id
    validates :modalities, presence: true, if: -> { need_complete_validation?(:modalities) }
    validates :france_connect_authorization_id, presence: true, if: -> { modalities == 'with_france_connect' && need_complete_validation?(:modalities) }
  end

  def available_modalities
    self.class::MODALITIES
  rescue NameError
    raise "Must declare a constant MODALITIES in the model #{self.class}, for example %w[with_france_connect with_spi]"
  end

  def associated_france_connect_authorization
    return nil if france_connect_authorization_id.blank?

    Authorization.find(france_connect_authorization_id)
  end
end
