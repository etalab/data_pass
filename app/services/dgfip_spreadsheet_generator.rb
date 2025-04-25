class DGFIPSpreadsheetGenerator
  def initialize(authorization_requests)
    @authorization_requests = authorization_requests
  end

  def perform
    sheet = create_sheet

    sheet.add_row(headers)

    @authorization_requests.each do |authorization_request|
      sheet.add_row(build_row(authorization_request))
    end

    generator
  end

  private

  def create_sheet
    workbook = generator.workbook
    workbook.add_worksheet(name: 'DataPass Habilitations')
  end

  def build_row(authorization_request)
    if authorization_request.raw_attributes_from_v1.present?
      build_legacy_row(authorization_request)
    else
      build_v2_row(authorization_request)
    end
  end

  def build_legacy_row(authorization_request)
    raw_attributes_from_v1 = JSON.parse(authorization_request.raw_attributes_from_v1)

    headers.map do |key|
      if key == 'additional_content'
        raw_attributes_from_v1[key].to_json
      elsif key == 'insee_payload'
        authorization_request.organization.insee_payload.to_json
      else
        raw_attributes_from_v1[key]
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def build_v2_row(authorization_request)
    [
      authorization_request.id,
      nil,
      # FIXME: pas forcément la dernière demande
      extract_previous_enrollment_id(authorization_request),
      extract_legacy_target_api(authorization_request),
      authorization_request.state,
      authorization_request.try(:intitule),
      authorization_request.try(:description),
      extract_legacy_demarche(authorization_request),
      authorization_request.try(:destinataire_donnees_caractere_personnel),
      authorization_request.try(:date_mise_en_production),
      authorization_request.try(:volumetrie_approximative),
      build_legacy_additional_content(authorization_request),
      authorization_request.created_at,
      authorization_request.events.order(created_at: :desc).limit(1).first&.created_at,
      authorization_request.organization.siret,
      authorization_request.organization.name,
      authorization_request.organization.insee_payload.to_json,
    ]
  end
  # rubocop:enable Metrics/AbcSize

  def headers
    %w[
      id
      copied_from_enrollment_id
      previous_enrollment_id
      target_api
      status
      intitule
      description
      demarche
      data_recipients
      date_mise_en_production
      volumetrie_approximative
      additional_content
      created_at
      updated_at
      siret
      nom_raison_sociale
      insee_payload
    ]
  end

  def extract_previous_enrollment_id(authorization_request)
    if authorization_request.definition.stage.exists? && authorization_request.definition.stage.type == 'production'
      extract_latest_sandbox_authorization_id(authorization_request) ||
        authorization_request.try(:france_connect_authorization_id)
    else
      authorization_request.try(:france_connect_authorization_id)
    end
  end

  # rubocop:disable Style/MultilineBlockChain
  def extract_latest_sandbox_authorization_id(authorization_request)
    authorization_request.authorizations.sort {
      authorization_request.authorizations.map(&:created_at).max
    }.find { |authorization|
      authorization.request.definition.stage.type == 'sandbox'
    }.try(:id)
  end
  # rubocop:enable Style/MultilineBlockChain

  # https://metabase.entreprise.api.gouv.fr/question/515
  # TODO mettre les bonnes valeurs
  def extract_legacy_demarche(authorization_request)
    {
      'api-impot-particulier-production' => 'activites_periscolaires',
      'api-impot-particulier2' => 'aides_sociales_facultatives',
      'api-impot-particulier3' => 'appel_api_impot_particulier',
      'api-impot-particulier4' => 'cantine_scolaire',
      'api-impot-particulier5' => 'carte_stationnement',
      'api-impot-particulier6' => 'carte_transport',
      'api-impot-particulier7' => 'default',
      'api-impot-particulier8' => 'eligibilite_lep',
      'api-impot-particulier9' => 'envoi_ecritures',
      'api-impot-particuliera' => 'migration_api_particulier',
      'api-impot-particulierb' => 'ordonnateur',
      'api-impot-particulierc' => 'place_creche',
      'api-impot-particulierd' => 'quotient_familial',
      'api-impot-particuliere' => 'stationnement_residentiel',
    }[authorization_request.form.id]
  end

  # https://metabase.entreprise.api.gouv.fr/question/514
  # rubocop:disable Metrics/AbcSize
  def build_legacy_additional_content(authorization_request)
    additional_content = {}

    additional_content['rgpd_general_agreement'] = true if authorization_request.validated?
    additional_content['specific_requirements'] = authorization_request.try(:specific_requirements)

    {
      date_prevue_mise_en_production: 'production_date',
      safety_certification_authority_name: 'autorite_homologation_nom',
      safety_certification_authority_function: 'autorite_homologation_fonction',
      safety_certification_begin_date: 'date_homologation',
      safety_certification_end_date: 'date_fin_homologation',
      recette_fonctionnelle: 'operational_acceptance_done',
    }.each do |old, new|
      next unless authorization_request.respond_to?(new)

      additional_content[old] = authorization_request.send(new)
    end

    if authorization_request.try(:modalities).present?
      {
        with_spi: 'acces_spi',
        with_etat_civil: 'acces_etat_civil'
      }.each do |old, new|
        next unless authorization_request.modalities.include?(old.to_s)

        additional_content[new] = true
      end
    end

    additional_content.compact.to_json
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def extract_legacy_target_api(authorization_request)
    if authorization_request.type.include?('Sandbox')
      authorization_request.type.split('::')[-1].underscore
    elsif authorization_request.form.id.include?('editeur')
      "#{authorization_request.type.split('::')[-1].underscore}_unique"
    else
      "#{authorization_request.type.split('::')[-1].underscore}_production"
    end
  end
  # rubocop:enable Metrics/AbcSize

  def generator
    @generator ||= Axlsx::Package.new
  end
end
