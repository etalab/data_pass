class IdentityProvider < StaticApplicationRecord
  PRO_CONNECT_IDENTITY_PROVIDER_UID = '71144ab3-ee1a-4401-b7b3-79b44f7daeeb'.freeze

  attr_accessor :id,
    :name,
    :unknown

  attr_writer :choose_organization_on_sign_in,
    :siret_verified,
    :can_link_to_organizations

  def self.backend
    Rails.application.config_for(:identity_providers).map do |uid, hash|
      new(id: uid.to_s, **hash.symbolize_keys)
    end
  end

  def self.find(id)
    super
  rescue StaticApplicationRecord::EntryNotFound
    unknown(id)
  end

  def self.unknown(id = nil)
    new(id: id&.to_s, name: 'Unknown', unknown: true)
  end

  def mon_compte_pro_identity_provider?
    id == PRO_CONNECT_IDENTITY_PROVIDER_UID
  end

  def choose_organization_on_sign_in?
    @choose_organization_on_sign_in.nil? || @choose_organization_on_sign_in
  end

  def can_link_to_organizations?
    @can_link_to_organizations.nil? ? false : @can_link_to_organizations
  end

  def siret_verified?
    @siret_verified.nil? ? false : @siret_verified
  end

  def unknown?
    @unknown.nil? ? false : @unknown
  end
end
