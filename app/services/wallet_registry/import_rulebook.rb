class WalletRegistry::ImportRulebook
  RULEBOOK_ATTRIBUTES = %w[name category version_label documentation_url schema_uri keywords provisional provisional_note source_details].freeze
  CLAIM_ATTRIBUTES = %w[label description requirement group_name position].freeze

  def self.call(payload)
    new(payload).call
  end

  def initialize(payload)
    @payload = payload.deep_stringify_keys
  end

  def call
    WalletRegistry::Rulebook.transaction do
      rulebook = WalletRegistry::Rulebook.find_or_initialize_by(@payload.slice('source', 'identifier', 'version'))
      rulebook.update!(@payload.slice(*RULEBOOK_ATTRIBUTES).merge('retired_at' => nil))
      import_claims(rulebook, import_formats(rulebook))
      rulebook.reload.refresh_search_text!
      retire_previous_versions(rulebook)
      rulebook
    end
  end

  private

  def import_formats(rulebook)
    @payload.fetch('formats').to_h do |format_payload|
      format = rulebook.formats.find_or_initialize_by(format: format_payload.fetch('format'))
      format.update!(format_payload.slice('vct', 'doctype'))
      [format.format, format]
    end
  end

  def import_claims(rulebook, formats)
    @payload.fetch('claims').each do |claim_payload|
      claim = rulebook.claims.find_or_initialize_by(identifier: claim_payload.fetch('identifier'))
      claim.update!(claim_payload.slice(*CLAIM_ATTRIBUTES))
      import_paths(claim, formats, claim_payload.fetch('paths'))
    end
  end

  def import_paths(claim, formats, paths)
    paths.each do |format, path|
      claim_path = claim.paths.find_or_initialize_by(rulebook_format: formats.fetch(format))
      claim_path.update!(path:)
    end
  end

  def retire_previous_versions(rulebook)
    WalletRegistry::Rulebook.available
      .where(source: rulebook.source, identifier: rulebook.identifier)
      .where.not(id: rulebook.id)
      .find_each { |previous| previous.update!(retired_at: Time.current) }
  end
end
