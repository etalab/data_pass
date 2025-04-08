class Import::AuthorizationRequests::APIR2PSandboxAttributes < Import::AuthorizationRequests::APIRialSandboxAttributes
  def affect_data
    affect_modalities

    super
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

    return if authorization_request.modalities.present?
    return if %w[refused validated].exclude?(authorization_request.state)

    skip_row!("no_modalities_in_status_#{authorization_request.state}")
  end
end
