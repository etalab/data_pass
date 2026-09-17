module DGFIPExtensions::AdressePostaleContactTechnique
  extend ActiveSupport::Concern

  included do
    add_attribute :contact_technique_adresse
    add_attribute :contact_technique_adresse_complement

    validates :contact_technique_adresse,
      presence: true,
      if: -> { need_complete_validation?(:contacts) }
  end
end
