FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    name { 'MyApp' }
    redirect_uri { 'https://app.com/callback' }
    owner factory: :user
  end

  factory :access_token, class: 'Doorkeeper::AccessToken' do
    application factory: :oauth_application
    resource_owner_id { application&.owner&.id }
    expires_in { 2.hours }
    scopes { 'public read_authorizations' }
  end
end
