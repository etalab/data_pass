def find_authorization_request_class_from_name(name)
  authorization_definition = find_authorization_definition_from_name(name)

  AuthorizationRequest.const_get(authorization_definition.id.classify)
end

def find_authorization_definition_from_name(name)
  AuthorizationDefinition.where(name:).first
end

def find_authorization_request_form_from_name(name)
  AuthorizationRequestForm.where(name:).first
end

def find_factory_trait_from_name(name)
  authorization_definition = find_authorization_definition_from_name(name)

  return authorization_definition.authorization_request_class.to_s.underscore.split('/').last if authorization_definition

  authorization_request_form = find_authorization_request_form_from_name(name)

  return unless authorization_request_form

  authorization_request_form.uid.underscore
end

# rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
def extract_state_from_french_status(status)
  case status
  when 'attente de modification', 'sujet à modification', 'modifier'
    'changes_requested'
  when 'attente', 'attentes', 'soumise', 'soumises', 'modérer'
    'submitted'
  when 'brouillon', 'brouillons'
    'draft'
  when 'refusée', 'refusées'
    'refused'
  when 'validée', 'validées'
    'validated'
  when 'archivée', 'archivées'
    'archived'
  when 'réouverte', 'réouvertes'
    'reopened'
  when 'révoquée', 'révoquées'
    'revoked'
  else
    raise "Unknown status #{status}"
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

# rubocop:disable Metrics/MethodLength
def create_authorization_requests_with_status(type, status = nil, count = 1, attributes = {})
  attributes[:applicant] ||= FactoryBot.create(:user, current_organization: attributes[:organization])

  if status
    FactoryBot.create_list(
      :authorization_request,
      count,
      extract_state_from_french_status(status),
      find_factory_trait_from_name(type),
      organization: attributes[:applicant].current_organization,
      **attributes,
    )
  else
    FactoryBot.create_list(
      :authorization_request,
      count,
      find_factory_trait_from_name(type),
      organization: attributes[:applicant].current_organization,
      **attributes,
    )
  end
end
# rubocop:enable Metrics/MethodLength
