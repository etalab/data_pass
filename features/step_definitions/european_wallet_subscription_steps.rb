Sachantque('l’adresse {string} est inscrite avec le profil « {} »') do |email, profile|
  create(:european_wallet_subscriber, email:, profile:)
end

Sachantque('{int} inscriptions ont été envoyées depuis ma connexion dans la minute') do |count|
  count.times do
    page.driver.post(european_wallet_subscriptions_path, european_wallet_subscriber: { email: 'deja@example.com', profile: 'organization' })
  end
  EuropeanWalletSubscriber.delete_all
end

Quand('je remplis le champ piège du bloc « Être prévenu »') do
  find_by_id('etre-prevenu-site', visible: :all).set('https://spam.example.com')
end

Alors('l’adresse {string} est inscrite une seule fois avec le profil « {} »') do |email, profile|
  subscribers = EuropeanWalletSubscriber.where(email:)

  expect(subscribers.count).to eq(1)
  expect(subscribers.first.profile).to eq(profile)
end

Alors('l’adresse {string} n’est pas inscrite') do |email|
  expect(EuropeanWalletSubscriber.where(email:)).to be_empty
end

Alors('aucune adresse n’est inscrite') do
  expect(EuropeanWalletSubscriber.count).to eq(0)
end

Alors('le champ « {} » est en erreur avec « {} »') do |label, message|
  field = find_field(label)
  expect(field[:'aria-invalid']).to eq('true')
  described_ids = field[:'aria-describedby'].split

  expect(described_ids.map { |id| find_by_id(id, visible: :all).text }.join(' ')).to include(message)
end

Alors('le choix « {} » est en erreur avec « {} »') do |legend, message|
  fieldset = find('fieldset.fr-fieldset--error', text: legend)
  labelled_by_ids = fieldset[:'aria-labelledby'].split
  expect(fieldset.all('input[type="radio"]').pluck(:'aria-invalid').uniq).to eq(['true'])

  expect(labelled_by_ids.map { |id| find_by_id(id, visible: :all).text }.join(' ')).to include(legend, message)
end

Alors('le focus est sur le champ « {} »') do |label|
  expect(page).to have_field(label, focused: true)
end

Alors('le focus est sur la confirmation d’inscription') do
  expect(page).to have_css('#etre-prevenu-confirmation:focus')
end
