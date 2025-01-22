module AuthorizationExtensions::Modalities
  extend ActiveSupport::Concern

  included do
    add_attribute :modalities,
      type: :array

    validates :modalities,
      presence: true,
      intersection: { in: ->(authorization_request) { authorization_request.available_modalities } },
      if: -> { need_complete_validation?(:modalities) || mandatory_modalities? }
  end

  def available_modalities
    self.class::MODALITIES
  rescue NameError
    raise "Must declare a constant MODALITIES in the model #{self.class}, for example %w[with_france_connect with_spi]"
  end

  def mandatory_modalities?
    false
  end

  def with_france_connect?
    modalities.include? 'with_france_connect'
  end
end
