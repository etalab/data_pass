module DGFIPExtensions::AdresseIpPubliqueProduction
  extend ActiveSupport::Concern

  included do
    add_attribute :adresse_ip_publique
    add_attribute :adresse_ip_publique_production

    validates :adresse_ip_publique_production,
      presence: true,
      if: -> { validation_context != :review && need_complete_validation?(:volumetrie) }

    validates :adresse_ip_publique_production,
      public_ip_address: true,
      if: -> { need_complete_validation?(:volumetrie) }
  end

  def adresse_ip_publique_editable? = false

  def adresse_ip_publique_displayed? = adresse_ip_publique.present?
end
