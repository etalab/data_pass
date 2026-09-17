module DGFIPExtensions::AdresseIpPublique
  extend ActiveSupport::Concern

  included do
    add_attribute :adresse_ip_publique

    validates :adresse_ip_publique,
      presence: true,
      public_ip_address: true,
      if: -> { need_complete_validation?(:basic_infos) }
  end
end
