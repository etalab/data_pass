class WalletRegistry::RulebookSources::ManualReading
  PATH = Rails.root.join('db/wallet_registry/releve_catalogue_ue.yml')
  RULEBOOK_KEYS = %w[version name category version_label documentation_url schema_uri keywords provisional_note].freeze

  def self.import!(path = PATH)
    new(path).rulebooks.map { |payload| WalletRegistry::ImportRulebook.call(payload) }
  end

  def initialize(path = PATH)
    @config = YAML.safe_load_file(path)
  end

  def rulebooks
    @config.fetch('rulebooks').map { |identifier, hash| rulebook_payload(identifier, hash) }
  end

  private

  def rulebook_payload(identifier, hash)
    hash.slice(*RULEBOOK_KEYS).merge(
      'source' => @config.fetch('source'),
      'identifier' => identifier,
      'provisional' => @config.fetch('provisional'),
      'source_details' => @config.fetch('source_details'),
      'formats' => hash.fetch('formats').map { |format, meta| format_payload(format, meta) },
      'claims' => claims_payload(hash.fetch('groups'))
    )
  end

  def format_payload(format, meta)
    { 'format' => format, 'vct' => Array(meta['vct_values']).first, 'doctype' => meta['doctype_value'] }
  end

  def claims_payload(groups)
    groups.flat_map { |group| group.fetch('claims').map { |claim| claim.merge('group_name' => group.fetch('name')) } }
      .each_with_index.map { |claim, index| claim_payload(claim, index + 1) }
  end

  def claim_payload(claim, position)
    {
      'identifier' => claim.fetch('id'),
      'label' => claim.fetch('label'),
      'description' => claim['description'],
      'requirement' => claim.fetch('presence'),
      'group_name' => claim.fetch('group_name'),
      'position' => position,
      'paths' => claim.fetch('paths')
    }
  end
end
