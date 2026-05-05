Alors('le bouton de suppression de la commune {string} est annoncé par son code aux lecteurs d’écran') do |code|
  expect(page).to have_field(with: code, visible: :all)
  expect(page).to have_css(%(button[aria-label="Retirer la commune #{code}"]), visible: :all)
end

Alors('chaque champ commune INSEE est annoncé avec sa position aux lecteurs d’écran') do
  expect(page).to have_css('input[name$="[communes_codes_insee][]"][aria-label="Communes (codes INSEE) n°1"]', visible: :all)
  expect(page).to have_css('input[name$="[communes_codes_insee][]"][aria-label="Communes (codes INSEE) n°2"]', visible: :all)
end

Alors('le groupe de codes INSEE utilise la légende DSFR conforme') do
  expect(page).to have_css('legend.fr-fieldset__legend', text: /Communes \(codes INSEE\)/, visible: :all)
end

Alors("la demande contient les conditions d'extraction CNOUS attendues") do
  authorization_request = AuthorizationRequest.last
  expect(authorization_request.communes_codes_insee).to match_array(%w[75056 69123])
  expect(authorization_request.echelon_bourse).to eq('5')
  expect(authorization_request.premiere_date_transmission).to eq('2026-09-01')
  expect(authorization_request.recurrence).to eq('annually')
end

Alors('les champs de codes INSEE acceptent les caractères alphanumériques de longueur 5') do
  expect(page).to have_css(
    'input[name$="[communes_codes_insee][]"][type="text"][inputmode="numeric"][pattern="[0-9AB]{5}"][maxlength="5"]',
    visible: :all
  )
end

Alors('la demande contient les codes communes INSEE {string} et {string}') do |code1, code2|
  expect(AuthorizationRequest.last.communes_codes_insee).to match_array([code1, code2])
end
