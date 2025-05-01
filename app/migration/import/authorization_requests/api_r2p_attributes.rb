class Import::AuthorizationRequests::APIR2PAttributes < Import::AuthorizationRequests::APIRialAttributes
  def extra_affect_data
    affect_form_uid
  end

  def demarche_to_form_uid
    form_uid = case enrollment_row['demarche']
      when 'ordonnateur'
        'api-r2p-ordonnateur-production'
      when 'appel_api_impot_particulier'
        'api-r2p-appel-spi-production'
      else
        'api-r2p-production'
      end

    form_uid += '-editeur' if enrollment_row['target_api'] =~ /_unique$/

    form_uid
  end
end
