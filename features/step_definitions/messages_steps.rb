Quand(/cette habilitation a un message (?:de l'|du) ([^\s+]*) avec comme corps "([^"]*)"$/) do |entity_kind, message|
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
