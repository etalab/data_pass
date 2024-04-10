class CategorieJuridique < StaticApplicationRecord
  attr_accessor :code,
    :libelle

  def self.all
    @all ||= Rails.application.config_for(:categories_juridiques).map do |code, libelle|
      new(code: code.to_s, libelle:)
    end
  end

  def id
    code
  end
end
