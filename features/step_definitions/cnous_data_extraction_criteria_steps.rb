Sachantque('l’API géo connaît la commune {string} nommée {string}') do |code, nom|
  stub_request(:get, "https://geo.api.gouv.fr/communes/#{code}?fields=nom,codeDepartement,codeRegion")
    .to_return(
      status: 200,
      body: { 'code' => code, 'nom' => nom, 'codeDepartement' => code[0, 2], 'codeRegion' => '11' }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
end

Alors('je vois le périmètre géographique en lecture seule contenant {string}') do |nom|
  within('[data-test="geographic-perimeter"]') do
    expect(page).to have_text(nom)
  end
end

Alors('le périmètre indique que les informations ne sont pas modifiables') do
  within('[data-test="geographic-perimeter"]') do
    expect(page).to have_text(/ces informations ne sont pas modifiables/i)
  end
end

Alors('le périmètre ne propose pas de voir toutes les communes') do
  within('[data-test="geographic-perimeter"]') do
    expect(page).to have_no_button('Voir toutes les communes')
  end
end

Alors('le résumé du périmètre est annoncé aux lecteurs d’écran') do
  expect(page).to have_css('[data-test="geographic-perimeter"] p[role="status"]')
end

Alors('la liste des communes est annoncée par son libellé aux lecteurs d’écran') do
  labels = page.all('[data-test="geographic-perimeter"] ul', visible: :all).map { |list| list['aria-label'] }
  expect(labels).to include('Communes incluses dans le périmètre')
end

Alors('le focus est sur la liste des communes du périmètre') do
  expect(page).to have_css('[data-test="geographic-perimeter"] ul:focus')
end

Alors('la demande contient le code commune INSEE {string}') do |code|
  expect(AuthorizationRequest.last.data['code_insee_entity']).to eq(code)
end

Alors('le bouton de suppression de la commune {string} est annoncé par son code aux lecteurs d’écran') do |code|
  expect(page).to have_field(with: code, visible: :all)
  expect(page).to have_css(%(button[aria-label="Retirer la commune #{code}"]), visible: :all)
end

Alors('chaque champ commune INSEE est annoncé avec sa position aux lecteurs d’écran') do
  expect(page).to have_css('input[name$="[manual_code_insee_communes][]"][aria-label="Communes (codes INSEE) n°1"]', visible: :all)
  expect(page).to have_css('input[name$="[manual_code_insee_communes][]"][aria-label="Communes (codes INSEE) n°2"]', visible: :all)
end

Alors('le groupe de codes INSEE utilise la légende DSFR conforme') do
  expect(page).to have_css('legend.fr-fieldset__legend', text: /Communes \(codes INSEE\)/, visible: :all)
end

Alors("la demande contient les conditions d'extraction CNOUS attendues") do
  authorization_request = AuthorizationRequest.last
  expect(authorization_request.manual_code_insee_communes).to match_array(%w[75056 69123])
  expect(authorization_request.echelon_bourse).to eq('5')
  expect(authorization_request.premiere_date_transmission).to eq('2026-09-01')
end

Alors('les champs de codes INSEE acceptent les caractères alphanumériques de longueur 5') do
  expect(page).to have_css(
    'input[name$="[manual_code_insee_communes][]"][type="text"][inputmode="numeric"][pattern="[0-9AB]{5}"][maxlength="5"]',
    visible: :all
  )
end

Alors('la demande contient les codes communes INSEE {string} et {string}') do |code1, code2|
  expect(AuthorizationRequest.last.manual_code_insee_communes).to match_array([code1, code2])
end

Alors('le focus est sur le dernier champ commune INSEE') do
  expect(page).to have_css('input:focus[name$="[manual_code_insee_communes][]"]', visible: :all)
  inputs = page.all('input[name$="[manual_code_insee_communes][]"]', visible: :all)
  focused_label = page.evaluate_script('document.activeElement.getAttribute("aria-label")')
  expect(focused_label).to eq(inputs.last['aria-label'])
end

Quand('je clique sur le bouton de suppression du dernier champ ajouté') do
  page.all('button', text: 'Retirer', visible: :all).last.click
end

Alors('le focus est sur le bouton {string}') do |label|
  expect(page).to have_css('button:focus', text: label, visible: :all)
end
