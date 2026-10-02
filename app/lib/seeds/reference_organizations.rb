class Seeds::ReferenceOrganizations
  ORGANIZATIONS = {
    dinum: { siret: '13002526500013', name: 'DINUM' },
    dgfip: { siret: '13000495500014', name: 'DGFIP' },
    menj: { siret: '11004301500012', name: 'Ministère de l’Éducation nationale' },
    mtes: { siret: '11006801200050', name: 'Ministère de la Transition écologique' },
    closed: { siret: '13002437500011', name: 'Secrétariat d’État chargé de l’Éducation prioritaire' },
    editor: { siret: '32816124500027', name: 'MGDIS' },
    clamart: { siret: '21920023500014', name: 'Ville de Clamart' },
    rhone: { siret: '22690001700014', name: 'Département du Rhône' },
  }.freeze

  STATS_COMMUNES_COUNT = 4

  attr_reader :stats_communes

  def perform
    @organizations = ORGANIZATIONS.transform_values { |organization| create_organization(**organization) }
    @stats_communes = Array.new(STATS_COMMUNES_COUNT) { |index| create_stats_commune("COMMUNE DE STATISTIQUES #{index + 1}") }
  end

  def fetch(key)
    @organizations.to_h.fetch(key)
  end

  private

  def create_organization(siret:, name:)
    Organization.create!(
      legal_entity_id: siret,
      last_mon_compte_pro_updated_at: DateTime.now,
      mon_compte_pro_payload: { label: name },
      insee_payload: insee_fixture(siret),
      last_insee_payload_updated_at: DateTime.now,
    )
  end

  def create_stats_commune(name)
    siret = Faker::Company.french_siret_number

    Organization.create!(
      legal_entity_id: siret,
      last_mon_compte_pro_updated_at: DateTime.now,
      mon_compte_pro_payload: { label: name },
      insee_payload: stats_commune_insee_payload(siret, name),
      last_insee_payload_updated_at: DateTime.now,
    )
  end

  def stats_commune_insee_payload(siret, name)
    payload = insee_fixture(ORGANIZATIONS.dig(:clamart, :siret))
    payload['etablissement'].merge!('siret' => siret, 'siren' => siret.first(9), 'nic' => siret.last(5))
    payload['etablissement']['uniteLegale']['denominationUniteLegale'] = name
    payload
  end

  def insee_fixture(siret)
    JSON.parse(Rails.root.join('spec', 'fixtures', 'insee', "#{siret}.json").read)
  end
end
