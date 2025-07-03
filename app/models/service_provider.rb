class ServiceProvider < StaticApplicationRecord
  include ActiveModel::Serialization

  attr_accessor :id,
    :name,
    :siret,
    :type,
    :already_integrated

  TYPES = { saas: 'saas', editor: 'editor' }.freeze

  def self.backend
    Rails.application.config_for(:service_providers).map do |uid, hash|
      build(uid, hash)
    end
  end

  def self.build(uid, hash)
    new(
      hash.slice(
        :name,
        :siret,
        :type,
        :already_integrated,
      ).merge(
        id: uid.to_s,
      )
    )
  end

  def self.editors
    all.select(&:editor?)
  end

  def already_integrated?(scope:)
    Array(already_integrated).include?(scope.to_s)
  end

  def editor?
    type == TYPES[:editor]
  end

  def saas?
    type == TYPES[:saas]
  end
end
