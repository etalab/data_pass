class Adhoc::Dpp147RecetteMetadonnees
  APPLICANT = { email: 'dem-metadonnees@yopmail.com', given_name: 'Camille', family_name: 'Recette' }.freeze
  CLAMART_SIRET = '21920023500014'.freeze
  DEVELOPER_EMAIL = 'dev-apie@yopmail.com'.freeze

  def call
    report(
      'Avec métadonnées' => create_request('Recette métadonnées — avec', campagne: 'migration-editeur-x', source: 'api', lot: 3),
      'Sans métadonnées' => create_request('Recette métadonnées — sans'),
      'Métadonnées remplacées puis effacées' => replaced_then_cleared_request
    )
  end

  private

  def create_request(intitule, **metadata)
    result = CreateAuthorizationRequestFromAPI.call(
      form_uid: 'api-entreprise',
      authorized_types: developer.authorization_request_types_for(:developer),
      authorization_request_params: ActionController::Parameters.new(intitule:),
      applicant_params: APPLICANT,
      siret: CLAMART_SIRET,
      user: developer,
      **metadata_context(metadata.presence)
    )

    raise "Création impossible : #{result.error.inspect}" if result.failure?

    result.authorization_request.tap { |authorization_request| make_organization_current_for_local_sign_in(authorization_request) }
  end

  def make_organization_current_for_local_sign_in(authorization_request)
    authorization_request.applicant.current_organization = authorization_request.organization
  end

  def replaced_then_cleared_request
    create_request('Recette métadonnées — remplacées puis effacées', campagne: 'premiere-vague').tap do |authorization_request|
      update_metadata(authorization_request, { campagne: 'seconde-vague' })
      update_metadata(authorization_request, nil)
    end
  end

  def update_metadata(authorization_request, metadata)
    UpdateAuthorizationRequestFromAPI.call!(
      authorization_request:,
      authorization_request_form: authorization_request.form,
      authorization_request_params: ActionController::Parameters.new,
      user: developer,
      **metadata_context(metadata, provided: true)
    )
  end

  def metadata_context(metadata, provided: metadata.present?)
    provided ? { api_metadata: metadata, api_metadata_provided: true } : {}
  end

  def developer
    @developer ||= User.find_by!(email: DEVELOPER_EMAIL)
  end

  def report(requests)
    requests.each do |label, authorization_request|
      $stdout.puts "#{label} : demande n°#{authorization_request.id} — metadata = #{authorization_request.reload.metadata.inspect}"
    end
  end
end
