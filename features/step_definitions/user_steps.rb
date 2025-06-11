Sachantque('il existe un utilisateur ayant l\'email {string}') do |email|
  @user = FactoryBot.create(:user, email: email)
end
