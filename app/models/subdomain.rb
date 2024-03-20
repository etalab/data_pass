class Subdomain < StaticApplicationRecord
  attr_accessor :id,
    :name,
    :authorization_definitions

  def self.all
    Rails.application.config_for(:subdomains).map do |uid, hash|
      build(uid, hash)
    end
  end

  def self.build(uid, hash)
    new(
      id: uid.to_s,
      name: hash[:name],
      authorization_definitions: AuthorizationDefinition.where(id: hash[:authorization_definition_ids])
    )
  end

  def authorization_request_types
    authorization_definitions.map(&:authorization_request_class).flatten.uniq.map(&:to_s)
  end
end
