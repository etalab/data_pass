class DataProvider < StaticApplicationRecord
  attr_accessor :id,
    :name,
    :logo,
    :link

  def self.all
    Rails.application.config_for(:data_providers).map do |uid, hash|
      new(id: uid.to_s, **hash.symbolize_keys)
    end
  end
end
