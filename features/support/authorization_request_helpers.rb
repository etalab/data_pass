def find_authorization_request_class_from_name(name, stage_type = nil)
  authorization_definition = find_authorization_definition_from_name(name, stage_type)

  AuthorizationRequest.const_get(authorization_definition.id.classify)
end

def find_authorization_definition_from_name(name, stage_type = nil)
  definitions = AuthorizationDefinition.where({ name: })

  if stage_type
    definitions.find { |definition| definition.stage.type == stage_type }
  else
    definitions.first
  end
end

def find_authorization_request_form_from_name(name)
  AuthorizationRequestForm.where(name:).first
end

def find_factory_trait_from_name(name, stage = nil, form = nil) # rubocop:disable Metrics/AbcSize
  authorization_definition = find_authorization_definition_from_name(name, extract_stage_type(stage))

  if form && authorization_definition
    target_form = authorization_definition.available_forms.find { |f| f.name == form }
    return target_form.uid.underscore if target_form
  end

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
  when 'brouillon et rempli', 'brouillons et remplis'
    'draft_and_filled'
  when 'refusée', 'refusées'
    'refused'
  when 'validée', 'validées'
    'validated'
  when 'archivée', 'archivées'
    'archived'
  when 'réouverte', 'réouvertes'
    'reopened'
  when 'réouverte et soumise', 'réouvertes et soumises'
    'reopened_and_submitted'
  when 'révoquée', 'révoquées'
    'revoked'
  when 'obsolète', 'obsolètes'
    'obsolete'
  when 'active', 'actives'
    'active'
  else
    raise "Unknown status #{status}"
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

def extract_stage_type(stage)
  case stage
  when 'Bac à sable'
    'sandbox'
  when 'Production'
    'production'
  end
end

# rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
def create_authorization_requests_with_status(type, status = nil, count = 1, stage = nil, form = nil, attributes = {})
  attributes[:applicant] ||= FactoryBot.create(:user, current_organization: attributes[:organization])

  if status
    FactoryBot.create_list(
      :authorization_request,
      count,
      extract_state_from_french_status(status),
      find_factory_trait_from_name(type, stage, form),
      organization: attributes[:applicant].current_organization,
      **attributes,
    )
  else
    FactoryBot.create_list(
      :authorization_request,
      count,
      find_factory_trait_from_name(type, stage, form),
      organization: attributes[:applicant].current_organization,
      **attributes,
    )
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/ParameterLists
