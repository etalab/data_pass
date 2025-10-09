Quand('je me rends sur la page des templates de messages pour {string}') do |_authorization_definition_name|
  visit instruction_message_templates_path
end

Sachantque('il existe un template de message {string} pour {string}') do |title, authorization_definition_name|
  authorization_definition = find_authorization_definition_from_name(authorization_definition_name)
  FactoryBot.create(:message_template,
    title:,
    authorization_definition_uid: authorization_definition.id,
    template_type: :refusal,
    content: 'Contenu du template')
end

Sachantque('il existe un template de message {string} avec le contenu {string} pour {string}') do |title, content, authorization_definition_name|
  authorization_definition = find_authorization_definition_from_name(authorization_definition_name)
  template_type = title.include?('Organisation non éligible') ? :refusal : :modification_request
  FactoryBot.create(:message_template,
    title:,
    authorization_definition_uid: authorization_definition.id,
    template_type:,
    content:)
end

Sachantque('il existe un template de message avec le contenu {string} pour {string}') do |content, authorization_definition_name|
  authorization_definition = find_authorization_definition_from_name(authorization_definition_name)
  FactoryBot.create(:message_template,
    title: 'Template de test',
    authorization_definition_uid: authorization_definition.id,
    template_type: :refusal,
    content:)
end

Sachantque('il existe {int} templates de type {string} pour {string}') do |count, template_type_french, authorization_definition_name|
  authorization_definition = find_authorization_definition_from_name(authorization_definition_name)
  template_type = template_type_french == 'Refus' ? :refusal : :modification_request

  count.times do |i|
    FactoryBot.create(:message_template,
      title: "Template #{i + 1}",
      authorization_definition_uid: authorization_definition.id,
      template_type:,
      content: "Contenu du template #{i + 1}")
  end
end

Quand('je clique sur {string} pour le template {string}') do |action, template_title|
  within('tr', text: template_title) do
    click_on action
  end
end

Quand('je sélectionne {string} dans le sélecteur de templates') do |template_title|
  within('.messages-templates-selector') do
    click_on template_title
  end
end
