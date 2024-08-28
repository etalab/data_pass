class Import::AuthorizationRequests::HubEEDilaAttributes < Import::AuthorizationRequests::Base
  def affect_data
    affect_contact('responsable_metier', 'administrateur_metier')
    affect_scopes
  end
end
