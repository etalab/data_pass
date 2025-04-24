class CreateSandboxOauthApp
  def perform
    return if Rails.env.production?

    app = create_sandbox_oauth_app

    print "Client_id: #{app.uid}\nClient_secret: #{app.secret}\n"
  end

  def dev_user
    user = User.find_or_initialize_by(email: "test@test.test")
    user.id = 900_000

    organization = dev_organization

    user.organizations << organization unless user.organizations.include?(organization)
    user.current_organization = organization
    user.roles = DataProvider.find('dgfip').authorization_definitions.map { |d| "#{d.id}:developer" }
    user.save!
    user
  end

  def dev_organization
    organization = Organization.find_or_initialize_by(siret: "91952090800014")
    organization.mon_compte_pro_payload = { manuel: true } if organization.mon_compte_pro_payload.blank?
    organization.last_mon_compte_pro_updated_at ||= DateTime.now
    organization.save!
    organization
  end

  def create_sandbox_oauth_app
    Doorkeeper::Application.create!(name: "DGFiP", owner: dev_user)
  end
end
