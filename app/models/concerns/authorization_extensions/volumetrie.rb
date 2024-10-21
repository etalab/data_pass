module AuthorizationExtensions::Volumetrie
  extend ActiveSupport::Concern

  included do
    add_attribute :volumetrie_appels_par_minute
    add_attribute :volumetrie_justification

    validates :volumetrie_appels_par_minute,
      presence: true,
      if: -> { need_complete_validation?(:volumetrie) }

    validates :volumetrie_justification,
      presence: true,
      if: -> { need_complete_validation?(:volumetrie) && volumetrie_is_not_the_smallest }
  end

  def volumetrie_is_not_the_smallest
    volumetrie_appels_par_minute.to_i > smallest_volumetrie
  end

  def smallest_volumetrie
    available_volumetries.values.min
  end

  def available_volumetries
    self.class::VOLUMETRIES
  rescue NameError
    raise "Must declare a constant VOLUMETRIES in the model #{self.class}, for example {'20 appels / minute' => 20}"
  end
end
