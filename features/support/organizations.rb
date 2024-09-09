def find_or_create_organization_by_name(name)
  Organization.find_by(siret: organization_name_to_siret(name)) ||
    create(:organization, name:, siret: organization_name_to_siret(name))
end

def organization_name_to_siret(name)
  {
    'Ville de Clamart' => '21920023500014',
  }[name] || (raise "Unknown organization name: #{name}")
end

def add_current_organization_to_user(user, organization)
  user.current_organization = organization
  user.organizations << organization unless user.organizations.include?(organization)
end
