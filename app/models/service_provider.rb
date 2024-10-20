class ServiceProvider < StaticApplicationRecord
  attr_accessor :id,
    :name,
    :siret,
    :type,
    :already_integrated

  def self.all
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

  def already_integrated?(scope:)
    Array(already_integrated).include?(scope.to_s)
  end

  def self.editors
    all.select(&:editor?)
  end
end
