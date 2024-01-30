class Editor < StaticApplicationRecord
  attr_accessor :id,
    :name,
    :siret

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
      ).merge(
        id: uid.to_s,
      )
    )
  end
end
