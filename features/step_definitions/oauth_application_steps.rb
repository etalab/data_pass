Sachantque('il existe une application OAuth {string} appartenant au développeur courant') do |name|
  @own_application = FactoryBot.create(:oauth_application, name:, owner: current_user)
end

Sachantque('il existe une application OAuth appartenant à un autre développeur') do
  other_user = FactoryBot.create(:user, :developer)
  @other_application = FactoryBot.create(:oauth_application, owner: other_user)
end

Quand("j'essaie de supprimer cette application directement") do
  page.driver.delete(developers_oauth_application_path(@other_application))
rescue ActiveRecord::RecordNotFound
  nil
end

Alors("l'application n'a pas été supprimée") do
  expect(Doorkeeper::Application.exists?(@other_application.id)).to be true
end
