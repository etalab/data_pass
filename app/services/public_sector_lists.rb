class PublicSectorLists
  PATH = Rails.root.join('config/public_sector_classification.yml')

  attr_reader :source, :legal_categories, :always_public_sirens, :never_public_sirens

  def self.instance
    @instance ||= new(YAML.load_file(PATH))
  end

  def initialize(data)
    @source = data.fetch('source').freeze
    @legal_categories = data.fetch('legal_categories').to_set.freeze
    @always_public_sirens = data.fetch('always_public_sirens').to_set.freeze
    @never_public_sirens = data.fetch('never_public_sirens').to_set.freeze
  end
end
