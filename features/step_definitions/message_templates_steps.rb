def map_template_type(type_french)
  case type_french.downcase
  when 'refus'
    :refusal
  when 'modifications'
    :modification_request
  when 'approbation'
    :approval
  else
    raise "Type de template inconnu: #{type_french}"
  end
end

Quand('je me rends sur la page des templates de messages pour {string}') do |_authorization_definition_name|
  visit instruction_message_templates_path
end

Sachantque('il existe un template de message de {word} {string} pour {string}') do |template_type_french, title, authorization_definition_name|
  authorization_definition = find_authorization_definition_from_name(authorization_definition_name)
  template_type = map_template_type(template_type_french)
  FactoryBot.create(:message_template,
    title:,
    authorization_definition_uid: authorization_definition.id,
    template_type:,
    content: 'Contenu du template')
end

Sachantque('il existe un template de message de {word} {string} avec le contenu {string} pour {string}') do |template_type_french, title, content, authorization_definition_name|
  authorization_definition = find_authorization_definition_from_name(authorization_definition_name)
  template_type = map_template_type(template_type_french)
  FactoryBot.create(:message_template,
    title:,
    authorization_definition_uid: authorization_definition.id,
    template_type:,
    content:)
end

Sachantque('il existe {int} templates de type {word} pour {string}') do |count, template_type_french, authorization_definition_name|
  authorization_definition = find_authorization_definition_from_name(authorization_definition_name)
  template_type = map_template_type(template_type_french)

  count.times do |i|
    FactoryBot.create(:message_template,
      title: "Template #{i + 1}",
      authorization_definition_uid: authorization_definition.id,
      template_type:,
      content: "Contenu du template #{i + 1}")
  end
end

Quand('je sélectionne {string} dans le sélecteur de templates') do |template_title|
  within('.messages-templates-selector') do
    click_on template_title
  end
end
