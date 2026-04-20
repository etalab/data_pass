Quand('un administrateur a effectué une modification avec la raison {string} et la raison privée {string} et le diff suivant :') do |public_reason, private_reason, table|
  authorization_request = AuthorizationRequest.last
  admin = create(:user, :admin)

  diff = table.hashes.to_h do |hash|
    [hash['champ'], [hash['ancienne valeur'], hash['nouvelle valeur']]]
  end

  Admin::CreateAdminChange.call(
    user: admin,
    authorization_request:,
    public_reason:,
    private_reason:,
    diff:,
  )
end

Quand('un administrateur a effectué une modification avec la raison {string} et la raison privée {string}') do |public_reason, private_reason|
  authorization_request = AuthorizationRequest.last
  admin = create(:user, :admin)

  Admin::CreateAdminChange.call(
    user: admin,
    authorization_request:,
    public_reason:,
    private_reason:,
  )
end

Quand('un administrateur a effectué une modification avec la raison {string} et le diff suivant :') do |public_reason, table|
  authorization_request = AuthorizationRequest.last
  admin = create(:user, :admin)

  diff = table.hashes.to_h do |hash|
    [hash['champ'], [hash['ancienne valeur'], hash['nouvelle valeur']]]
  end

  Admin::CreateAdminChange.call(
    user: admin,
    authorization_request:,
    public_reason:,
    diff:,
  )
end

Quand('un administrateur a effectué une modification avec la raison {string}') do |public_reason|
  authorization_request = AuthorizationRequest.last
  admin = create(:user, :admin)

  Admin::CreateAdminChange.call(
    user: admin,
    authorization_request:,
    public_reason:,
  )
end
