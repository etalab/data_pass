def find_or_create_organization_by_name(name)
  Organization.find_by(siret: organization_name_to_siret(name)) ||
    create(:organization, name:, siret: organization_name_to_siret(name))
end

def organization_name_to_siret(name)
  {
    'Ville de Clamart' => '21920023500014',
  }[name] || (raise "Unknown organization name: #{name}")
end
