def find_form_from_name(name)
  AuthorizationRequestForm.where(name:).first
end

def find_factory_trait_from_name(name)
  find_form_from_name(name).authorization_request_class.to_s.underscore.split('/').last
end

def extract_state_from_french_status(status)
  case status
  when 'attente', 'attentes', 'soumise', 'soumises', 'modérer'
    'submitted'
  when 'brouillon', 'brouillons'
    'draft'
  when 'refusée', 'refusées'
    'rejected'
  when 'validée', 'validées'
    'validated'
  end
end

def create_authorization_requests_with_status(type, status = nil, count = 1)
  if status
    FactoryBot.create_list(
      :authorization_request,
      count,
      extract_state_from_french_status(status),
      find_factory_trait_from_name(type),
    )
  else
    FactoryBot.create_list(
      :authorization_request,
      count,
      find_factory_trait_from_name(type),
    )
  end
end
