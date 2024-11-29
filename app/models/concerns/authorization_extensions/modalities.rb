module AuthorizationExtensions::Modalities
  extend ActiveSupport::Concern

  included do
    add_attributes :modalities

    validates :modalities,
      presence: true,
      if: -> { need_complete_validation?(:modalities) }

    validate :modalities_in_available_values,
      if: -> { need_complete_validation?(:modalities) }
  end

  def modalities_in_available_values
    if modalities.is_a? Array
      errors.add(:modalities) unless (modalities - available_modalities).empty?
    elsif available_modalities.exclude?(modalities)
      errors.add(:modalities)
    end
  end

  def available_modalities
    self.class::MODALITIES
  rescue NameError
    raise "Must declare a constant MODALITIES in the model #{self.class}, for example %w[with_france_connect with_spi]"
  end
end
