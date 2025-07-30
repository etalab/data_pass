def find_or_create_organization_by_name(name)
  Organization.find_by(legal_entity_id: organization_name_to_siret(name), legal_entity_registry: 'insee_sirene') ||
    create(:organization, name:, siret: organization_name_to_siret(name))
end

def organization_name_to_siret(name)
  {
    'Ville de Clamart' => '21920023500014',
    'DINUM' => '13002526500013',
  }[name] || (raise "Unknown organization name: #{name}")
end

def add_current_organization_to_user(user, organization, verified: true)
  user.add_to_organization(organization, current: true, verified:)
end
