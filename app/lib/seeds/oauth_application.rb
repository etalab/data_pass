class Seeds::OauthApplication
  def initialize(context)
    @accounts = context.accounts
  end

  def perform
    Doorkeeper::Application.create!(
      name: 'API Entreprise',
      uid: 'client_id',
      secret: 'so_secret',
      owner: @accounts.find('dev-apie@yopmail.com'),
    )
  end
end
