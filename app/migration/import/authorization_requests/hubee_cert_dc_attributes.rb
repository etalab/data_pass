class Import::AuthorizationRequests::HubEECertDCAttributes < Import::AuthorizationRequests::Base
  def affect_data
    affect_contact('responsable_metier', 'administrateur_metier')
  end
end
