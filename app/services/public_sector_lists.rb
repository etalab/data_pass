class PublicSectorLists
  PATH = Rails.root.join('config/public_sector_classification.yml')

  attr_reader :source, :legal_categories, :whitelisted_sirens, :blacklisted_sirens

  def self.instance
    @instance ||= new(YAML.load_file(PATH))
  end

  def initialize(data)
    @source = data.fetch('source').freeze
    @legal_categories = data.fetch('legal_categories').to_set.freeze
    @whitelisted_sirens = data.fetch('whitelisted_sirens').to_set.freeze
    @blacklisted_sirens = data.fetch('blacklisted_sirens').to_set.freeze
  end
end
