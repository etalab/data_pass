class Import::AuthorizationRequests::APIFicobaSandboxAttributes < Import::AuthorizationRequests::APIRialSandboxAttributes
  def affect_data
    affect_modalities
    affect_form_uid

    super

    skip_row!("no_modalities_in_status_#{authorization_request.state}") unless authorization_request.modalities.present?
  end

  def affect_modalities
    authorization_request.modalities ||= []

    {
      'acces_ficoba_iban' => 'with_ficoba_iban',
      'acces_ficoba_siren' => 'with_ficoba_siren',
      'acces_ficoba_spi' => 'with_ficoba_spi',
      'acces_ficoba_personne_morale' => 'with_ficoba_personne_morale',
      'acces_ficoba_personne_physique' => 'with_ficoba_personne_physique',
    }.each do |from, to|
      next unless additional_content[from]

      authorization_request.modalities = authorization_request.modalities.concat([to])
    end

    authorization_request.modalities = authorization_request.modalities.uniq
  end

  def demarche_to_form_uid
    'api-ficoba-sandbox'
  end
end
