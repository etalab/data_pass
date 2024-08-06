Quand('je clique sur la bulle de messagerie') do
  find('.message-bubble-cta').click
end

Quand(/cette habilitation a un message (?:de l'|du )([^\s+]*) avec comme corps "([^"]*)"$/) do |entity_kind, message|
  authorization_request = AuthorizationRequest.last

  case entity_kind
  when 'demandeur'
    SendMessageToInstructors.call(
      authorization_request:,
      user: authorization_request.applicant,
      message_params: {
        body: message,
      }
    )
  when 'instructeur'
    create_instructor(authorization_request.definition.name) if authorization_request.definition.instructors.blank?

    SendMessageToApplicant.call(
      authorization_request:,
      user: authorization_request.definition.instructors.first,
      message_params: {
        body: message,
      }
    )
  else
    raise "Unknown entity kind: #{entity_kind}"
  end
end

Alors('il y a une bulle de messagerie') do
  expect(page).to have_css('.message-bubble-cta')
end

Alors('il n\'y a pas de bulle de messagerie') do
  expect(page).to have_no_css('.message-bubble-cta')
end

Alors('je vois un badge de nouveau message contenant {string}') do |message|
  expect(page).to have_css('.unread-message-dot', text: message)
end

Alors('il n\'y a pas de badge de nouveau message') do
  expect(page).to have_no_css('.unread-message-dot')
end
