def find_authorization_definition_from_name(name)
  AuthorizationDefinition.where(name:).first
end

def find_factory_trait_from_name(name)
  find_authorization_definition_from_name(name).authorization_request_class.to_s.underscore.split('/').last
end

def extract_state_from_french_status(status)
  case status
  when 'attente de modification'
    'changes_requested'
  when 'attente', 'attentes', 'soumise', 'soumises', 'modérer'
    'submitted'
  when 'brouillon', 'brouillons'
    'draft'
  when 'refusée', 'refusées'
    'refused'
  when 'validée', 'validées'
    'validated'
  else
    raise "Unknown status #{status}"
  end
end

# rubocop:disable Metrics/MethodLength
def create_authorization_requests_with_status(type, status = nil, count = 1, applicant = nil)
  applicant ||= FactoryBot.create(:user)

  if status
    FactoryBot.create_list(
      :authorization_request,
      count,
      extract_state_from_french_status(status),
      find_factory_trait_from_name(type),
      applicant:,
      organization: applicant.current_organization,
    )
  else
    FactoryBot.create_list(
      :authorization_request,
      count,
      find_factory_trait_from_name(type),
      applicant:,
      organization: applicant.current_organization,
    )
  end
end
# rubocop:enable Metrics/MethodLength
