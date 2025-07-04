class Subdomain < StaticApplicationRecord
  attr_accessor :id,
    :name,
    :title,
    :tagline,
    :authorization_definitions

  def self.backend
    Rails.application.config_for(:subdomains).map do |uid, hash|
      build(uid, hash)
    end
  end

  def self.build(uid, hash)
    new(
      hash.slice(
        :name,
        :title,
        :tagline,
      ).merge(
        id: uid.to_s,
        authorization_definitions: AuthorizationDefinition.where(id: hash[:authorization_definition_ids]),
      )
    )
  end

  def self.find_for_authorization_request(authorization_request)
    all.find do |subdomain|
      subdomain.authorization_definitions.map(&:id).include?(authorization_request.definition.id)
    end
  end

  def authorization_request_types
    authorization_definitions.map(&:authorization_request_class).flatten.uniq.map(&:to_s)
  end
end
