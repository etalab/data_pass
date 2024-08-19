class Editor < StaticApplicationRecord
  attr_accessor :id,
    :name,
    :siret,
    :already_integrated

  def self.all
    Rails.application.config_for(:editors).map do |uid, hash|
      build(uid, hash)
    end
  end

  def self.build(uid, hash)
    new(
      hash.slice(
        :name,
        :siret,
        :already_integrated,
      ).merge(
        id: uid.to_s,
      )
    )
  end

  def already_integrated?(scope:)
    Array(already_integrated).include?(scope.to_s)
  end
end
