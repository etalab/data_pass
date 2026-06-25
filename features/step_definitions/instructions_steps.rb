Alors("je suis sur l'espace instruction") do
  expect(page).to have_current_path(/instruction/)
end

Quand('je me rends sur la liste des formulaires') do
  visit instruction_authorization_definitions_path
end

Alors('le formulaire {string} affiche {int} demande(s) validée(s) et {int} demande(s) en cours') do |name, validated_count, submitted_count|
  definition = find_authorization_definition_from_name(name)

  within(css_id(definition)) do
    counts = all('.fr-card__footer span:not(.fr-badge)').map(&:text)
    expect(counts).to eq([validated_count.to_s, submitted_count.to_s])
  end
end
