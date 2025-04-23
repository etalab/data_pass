class Import::AuthorizationRequests::APIR2PSandboxAttributes < Import::AuthorizationRequests::APIRialSandboxAttributes
  def affect_data
    affect_modalities
    affect_form_uid

    super

    skip_row!("no_modalities_in_status_#{authorization_request.state}") unless authorization_request.modalities.present?
  end

  def affect_modalities
    authorization_request.modalities ||= []

    {
      'acces_etat_civil' => 'with_acces_etat_civil',
      'acces_spi' => 'with_acces_spi',
      'acces_etat_civil_et_adresse' => 'with_acces_etat_civil_et_adresse',
      'acces_etat_civil_restitution_spi' => 'with_acces_etat_civil_restitution_spi',
      'acces_etat_civil_complet_adresse' => 'with_acces_etat_civil_complet_adresse',
      'acces_etat_civil_degrade_adresse' => 'with_acces_etat_civil_degrade_adresse',
    }.each do |from, to|
      next unless additional_content[from]

      authorization_request.modalities = authorization_request.modalities.concat([to])
    end

    authorization_request.modalities = authorization_request.modalities.uniq
  end

  def demarche_to_form_uid
    case enrollment_row['demarche']
    when 'ordonnateur'
      'api-r2p-ordonnateur-sandbox'
    when 'appel_api_impot_particulier'
      'api-r2p-appel-spi-sandbox'
    else
      'api-r2p-sandbox'
    end
  end
end
