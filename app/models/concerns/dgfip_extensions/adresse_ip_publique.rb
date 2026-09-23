module DGFIPExtensions::AdresseIpPublique
  extend ActiveSupport::Concern

  included do
    add_attribute :adresse_ip_publique

    validates :adresse_ip_publique,
      presence: true,
      if: -> { validation_context != :review && need_complete_validation?(:basic_infos) }

    validates :adresse_ip_publique,
      public_ip_address: true,
      if: -> { need_complete_validation?(:basic_infos) }
  end
end
