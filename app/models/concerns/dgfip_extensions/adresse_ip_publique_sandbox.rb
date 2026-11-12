module DGFIPExtensions::AdresseIpPubliqueSandbox
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

  def adresse_ip_publique_sandbox = adresse_ip_publique

  def adresse_ip_publique_sandbox=(value)
    self.adresse_ip_publique = value
  end

  def adresse_ip_publique_sandbox_editable? = true

  def adresse_ip_publique_sandbox_displayed? = true
end
