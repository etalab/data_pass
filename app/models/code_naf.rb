class CodeNAF < StaticApplicationRecord
  attr_accessor :code,
    :libelle

  def self.backend
    Rails.application.config_for(:codes_naf).map do |code, libelle|
      new(code: code.to_s, libelle:)
    end
  end

  def self.find(id)
    super(id.delete('.').strip)
  end

  def id
    code
  end
end
