class Seeds::BoursiersHabilitationType
  def initialize(_context); end

  def perform
    HabilitationType.create!(
      name: 'Boursiers',
      description: 'Extraction des données des boursiers CNOUS (périmètre géographique dérivé de l’identité INSEE).',
      kind: 'api',
      data_provider: DataProvider.find_by!(slug: 'menj'),
      cgu_link: 'https://example.org/cgu',
      support_email: 'support@yopmail.com',
      blocks: [
        { 'name' => 'basic_infos' },
        { 'name' => 'cnous_data_extraction_criteria' },
        { 'name' => 'contacts' },
      ],
      contact_types: ['contact_metier'],
      features: { 'messaging' => true, 'transfer' => true, 'reopening' => true },
      scopes: [],
      custom_labels: {}
    )
  end
end
