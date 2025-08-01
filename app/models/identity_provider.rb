class IdentityProvider < StaticApplicationRecord
  attr_accessor :id,
    :name

  attr_writer :choose_organization_on_sign_in,
    :siret_verified,
    :can_link_to_organizations,
    :linked_to_organizations_verified

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

  def self.unknown(id)
    new(id: id.to_s, name: 'Unknown')
  end

  def mon_compte_pro_identity_provider?
    id == '71144ab3-ee1a-4401-b7b3-79b44f7daeeb'
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

  def linked_to_organizations_verified?
    @linked_to_organizations_verified.nil? ? false : @linked_to_organizations_verified
  end
end
