FactoryBot.define do
  factory :authorization_request do
    initialize_with do
      attributes[:type].constantize.new(attributes.stringify_keys)
    end

    terms_of_service_accepted { true }
    data_protection_officer_informed { true }
    form_uid { 'hubee-cert-dc' }
    type { 'AuthorizationRequest::HubEECertDC' }
    external_provider_id { nil }

    after(:build) do |authorization_request, evaluator|
      authorization_request.data.stringify_keys!

      authorization_request.form.initialize_with.each do |key, value|
        next if authorization_request.data[key.to_s].present?

        authorization_request.public_send(:"#{key}=", value)
      end

      if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
        authorization_request.contact_types.each do |contact_type|
          {
            'family_name' => "Dupont #{contact_type.to_s.humanize}",
            'given_name' => "Jean #{contact_type.to_s.humanize}",
            'email' => "jean.dupont.#{contact_type}@gouv.fr",
            'phone_number' => '0836656565',
            'job_title' => "Agent #{contact_type.to_s.humanize}",
          }.each do |attribute, value|
            next if authorization_request.public_send(:"#{contact_type}_#{attribute}").present?

            authorization_request.public_send(:"#{contact_type}_#{attribute}=", value)
          end
        end

        authorization_request.extra_checkboxes.each do |checkbox|
          authorization_request.public_send(:"#{checkbox}=", '1')
        end
      end
    end

    after(:build) do |authorization_request|
      if authorization_request.applicant.nil? && authorization_request.organization.nil?
        applicant = create(:user)
        organization = create(:organization)
        applicant.add_to_organization(organization, current: true)

        authorization_request.applicant = applicant
        authorization_request.organization = organization
      elsif authorization_request.applicant.nil?
        applicant = create(:user)
        applicant.add_to_organization(authorization_request.organization, current: true)

        authorization_request.applicant = applicant
      elsif authorization_request.organization.nil?
        applicant = authorization_request.applicant
        organization = applicant.organizations.first || create(:organization)
        applicant.add_to_organization(organization, current: true) if organization.users.exclude?(applicant)

        authorization_request.organization = organization
      end
    end

    after(:create) do |authorization_request, evaluator|
      evaluator.documents.each do |document|
        authorization_request.public_send(document).attach(
          io: Rails.root.join('spec/fixtures/dummy.pdf').open,
          filename: 'dummy.pdf',
          content_type: 'application/pdf',
        )
      end
    end

    transient do
      fill_all_attributes { false }
      documents { [] }
    end

    trait :no_checkboxes do
      terms_of_service_accepted { false }
      data_protection_officer_informed { false }
    end

    trait :draft do
      state { 'draft' }
    end

    trait :draft_and_filled do
      state { 'draft' }
      fill_all_attributes { true }
    end

    trait :archived do
      state { 'archived' }
    end

    trait :submitted do
      state { 'submitted' }
      fill_all_attributes { true }

      after(:create) do |authorization_request|
        changelog = CreateAuthorizationRequestChangelog.call(authorization_request:, user: authorization_request.applicant).changelog

        CreateAuthorizationRequestEventModel.call(
          authorization_request:,
          user: authorization_request.applicant,
          event_name: 'submit',
          event_entity: :changelog,
          changelog:,
        )
      end
    end

    trait :changes_requested do
      submitted

      state { 'changes_requested' }
      fill_all_attributes { true }

      after(:build) do |authorization_request|
        authorization_request.modification_requests << build(:instructor_modification_request, authorization_request:)
      end
    end

    trait :refused do
      submitted

      state { 'refused' }
      fill_all_attributes { true }

      after(:build) do |authorization_request|
        authorization_request.denials << build(:denial_of_authorization, authorization_request:)
      end
    end

    trait :revoked do
      validated

      state { 'revoked' }
      fill_all_attributes { true }

      after(:build) do |authorization_request|
        authorization_request.revocations << build(:revocation_of_authorization, authorization_request:)
      end

      after(:create) do |authorization_request|
        authorization_request.authorizations.update_all(revoked: true) # rubocop:disable Rails/SkipsModelValidations
      end
    end

    trait :validated do
      submitted

      state { 'validated' }
      fill_all_attributes { true }
      last_validated_at { Time.zone.now }

      after(:create) do |authorization_request|
        CreateAuthorization.call(authorization_request:)
      end
    end

    trait :reopened do
      validated

      after(:create) do |authorization_request|
        ReopenAuthorization.call(
          authorization: authorization_request.latest_authorization,
          user: authorization_request.applicant,
        )
      end
    end

    trait :reopened_and_submitted do
      reopened

      after(:create) do |authorization_request|
        SubmitAuthorizationRequest.call(
          authorization_request: authorization_request,
          user: authorization_request.applicant,
        )
      end
    end

    trait :has_previous_authorization_validated do
      after(:create) do |authorization_request|
        if authorization_request.authorizations.empty?
          previous_authorization_created_at = authorization_request.created_at
        else
          date_offset = (authorization_request.latest_authorization.created_at - authorization_request.created_at) / 2
          previous_authorization_created_at = authorization_request.created_at + date_offset
        end

        previous_stage = authorization_request.definition.stage.previous_stages[0]

        authorization_request.authorizations << Authorization.create!(
          request: authorization_request,
          applicant: authorization_request.applicant,
          authorization_request_class: previous_stage[:definition].authorization_request_class,
          data: authorization_request.data.presence || { 'what' => 'ever' },
          created_at: previous_authorization_created_at,
        )
      end
    end

    trait :with_basic_infos do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          authorization_request.intitule ||= 'Demande d\'accès à la plateforme fournisseur'
          authorization_request.description ||= 'Description de la demande'
        end
      end
    end

    trait :with_technical_team do
      after(:build) do |authorization_request, evaluator|
        authorization_request.technical_team_type = 'internal' if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
      end
    end

    trait :with_personal_data do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          authorization_request.destinataire_donnees_caractere_personnel ||= 'Agents'
          authorization_request.duree_conservation_donnees_caractere_personnel ||= '1'
        end
      end
    end

    trait :with_cadre_juridique do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          authorization_request.cadre_juridique_nature ||= 'Loi numérique'
          authorization_request.cadre_juridique_url ||= 'https://www.legifrance.gouv.fr/affichTexte.do?cidTexte=JORFTEXT000000886460'
        end
      end
    end

    trait :with_france_connect_eidas do
      after(:build) do |authorization_request, evaluator|
        authorization_request.france_connect_eidas ||= 'eidas_1' if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
      end
    end

    trait :with_scopes do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          next if authorization_request.scopes.any?

          authorization_request.scopes ||= []
          authorization_request.scopes << authorization_request.available_scopes.first.value
        end
      end
    end

    trait :with_safety_certification do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          authorization_request.safety_certification_authority_name ||= 'Josiane Homologation'
          authorization_request.safety_certification_authority_function ||= "Représentant de l'autorité d'homologation des joints d'étanchéité de conduits d'évacuation de climatiseurs de morgue"
          authorization_request.safety_certification_begin_date ||= '2025-05-22'
          authorization_request.safety_certification_end_date ||= '2050-05-23'
          authorization_request.safety_certification_document.attach(
            [
              {
                io: Rails.root.join('spec/fixtures/dummy.pdf').open,
                filename: 'dummy.pdf',
                content_type: 'application/pdf',
              }
            ]
          )
        end
      end
    end

    trait :with_modalities do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          modality = authorization_request.available_modalities.last
          authorization_request.modalities = [modality] if authorization_request.modalities.blank?
        end
      end
    end

    trait :with_operational_acceptance do
      after(:build) do |authorization_request, evaluator|
        authorization_request.operational_acceptance_done = '1' if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
      end
    end

    trait :with_volumetrie do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          authorization_request.volumetrie_appels_par_minute ||= 50
          authorization_request.volumetrie_justification ||= nil
        end
      end
    end

    trait :with_attestation_fiscale do
      after(:build) do |authorization_request|
        authorization_request.attestation_fiscale.attach(
          [
            {
              io: Rails.root.join('spec/fixtures/dummy.pdf').open,
              filename: 'dummy.pdf',
              content_type: 'application/pdf'
            }
          ]
        )
      end
    end

    trait :with_france_connect do
      transient do
        france_connect_authorization { nil }
      end

      after(:build) do |authorization_request, evaluator|
        if evaluator.france_connect_authorization.present?
          authorization_request.france_connect_authorization_id = evaluator.france_connect_authorization.id.to_s
        elsif authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          validated_france_connect_authorization_request = create(:authorization_request, :france_connect, :validated, applicant: authorization_request.applicant, organization: authorization_request.organization)
          authorization_request.france_connect_authorization_id = validated_france_connect_authorization_request.latest_authorization.id.to_s
        end
      end
    end

    trait :hubee_cert_dc do
      type { 'AuthorizationRequest::HubEECertDC' }
    end

    trait :portail_hubee_demarche_certdc do
      hubee_cert_dc
      form_uid { 'hubee-cert-dc' }
    end

    trait :hubee_dila do
      type { 'AuthorizationRequest::HubEEDila' }
      form_uid { 'hubee-dila' }

      with_scopes
    end

    trait :portail_hubee_demarches_dila do
      hubee_dila
    end

    trait :api_entreprise do
      type { 'AuthorizationRequest::APIEntreprise' }
      form_uid { 'api-entreprise' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
    end

    %w[
      api-entreprise-marches-publics
      api-entreprise-aides-publiques
      api-entreprise-subventions-associations
      api-entreprise-portail-gru-preremplissage
      api-entreprise-portail-gru-instruction
      api-entreprise-detection-fraude
      api-entreprise-editeur
      api-entreprise-e-attestations
      api-entreprise-provigis
      api-entreprise-achat-solution
      api-entreprise-mgdis
      api-entreprise-atexo
      api-entreprise-setec-atexo
      api-entreprise-inetum
      api-entreprise-entrouvert
    ].each do |form_uid|
      trait form_uid.tr('-', '_') do
        api_entreprise
        form_uid { form_uid }
      end
    end

    trait :api_particulier do
      type { 'AuthorizationRequest::APIParticulier' }
      form_uid { 'api-particulier' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
    end

    %w[
      api-particulier-aiga
      api-particulier-abelium
      api-particulier-agora-plus
      api-particulier-amiciel-malice
      api-particulier-arpege-concerto
      api-particulier-bl-enfance-berger-levrault
      api-particulier-cantine-de-france
      api-particulier-ccas-arche-mc2
      api-particulier-ccas-arpege
      api-particulier-ccas-melissandre-afi
      api-particulier-ccas-paxtel
      api-particulier-city-family-mushroom-software
      api-particulier-civil-enfance-ciril-group
      api-particulier-cosoluce-fluo
      api-particulier-docaposte-fast
      api-particulier-entrouvert-publik
      api-particulier-jcdeveloppement-familyclic
      api-particulier-jvs-mairistem
      api-particulier-nfi
      api-particulier-odyssee-informatique-pandore
      api-particulier-qiis-eticket
      api-particulier-sigec-maelis
      api-particulier-teamnet-axel
      api-particulier-technocarte-ile
      api-particulier-waigeo-myperischool
      api-particulier-3d-ouest
      api-particulier-coexya
      api-particulier-agedi-proxima-enf
      api-particulier-ecorestauration-loyfeey
      api-particulier-extenso-partner-extenso-cloud
      api-particulier-capdemat-capdemat-evolution
      api-particulier-kosmos-education
      api-particulier-monkey-factory-maasify
      api-particulier-esabora-pourmesdossiers
      api-particulier-airweb
      api-particulier-noethys
      api-particulier-resagenda
      api-particulier-carte-plus
      api-particulier-ganesh-education
      api-particulier-paxtel
      api-particulier-ypok
      api-particulier-ars-data
      api-particulier-e1os
      api-particulier-acheteza
      api-particulier-dialog
      api-particulier-tarification-municipale-enfance
      api-particulier-aides-facultatives-regionales
      api-particulier-aides-facultatives-departementales
      api-particulier-tarification-cantines-lycees
      api-particulier-tarification-cantines-colleges
      api-particulier-aides-sociales-ccas
      api-particulier-aides-sociales-ccas-dont-facultatives
      api-particulier-tarification-transports
      api-particulier-gestion-rh-secteur-public
    ].each do |form_uid|
      trait form_uid.tr('-', '_') do
        api_particulier
        form_uid { form_uid }
      end
    end

    trait :api_captchetat do
      type { 'AuthorizationRequest::APICaptchEtat' }

      form_uid { 'api-captchetat' }
      with_basic_infos
    end

    trait :api_impot_particulier_common do
      type { 'AuthorizationRequest::APIImpotParticulier' }

      transient do
        skip_scopes_build { false }
      end

      form_uid { 'api-impot-particulier-production' }

      after(:build) do |authorization_request, evaluator|
        authorization_request.scopes << 'dgfip_annee_n_moins_1' if !evaluator.skip_scopes_build && authorization_request.scopes.empty?
      end

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_modalities
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_impot_particulier do
      api_impot_particulier_common

      has_previous_authorization_validated
    end

    trait :api_impot_particulier_production do
      api_impot_particulier_common

      has_previous_authorization_validated
    end

    trait :api_impot_particulier_production_editeur do
      api_impot_particulier_common

      form_uid { 'api-impot-particulier-production-editeur' }
    end

    trait :api_impot_particulier_stationnement_residentiel_sandbox do
      api_impot_particulier
      form_uid { 'api-impot-particulier-stationnement-residentiel-sandbox' }
    end

    trait :api_impot_particulier_stationnement_residentiel_production do
      api_impot_particulier
      form_uid { 'api-impot-particulier-stationnement-residentiel-production' }
    end

    trait :api_impot_particulier_stationnement_residentiel_editeur do
      api_impot_particulier
      form_uid { 'api-impot-particulier-stationnement-residentiel-editeur' }
    end

    trait :api_impot_particulier_place_creche_sandbox do
      api_impot_particulier
      form_uid { 'api-impot-particulier-place-creche-sandbox' }
    end

    trait :api_impot_particulier_place_creche_production do
      api_impot_particulier
      form_uid { 'api-impot-particulier-place-creche-production' }
    end

    trait :api_impot_particulier_place_creche_editeur do
      api_impot_particulier
      form_uid { 'api-impot-particulier-place-creche-editeur' }
    end

    trait :api_impot_particulier_activites_periscolaires_sandbox do
      api_impot_particulier
      form_uid { 'api-impot-particulier-activites-periscolaires-sandbox' }
    end

    trait :api_impot_particulier_activites_periscolaires_production do
      api_impot_particulier
      form_uid { 'api-impot-particulier-activites-periscolaires-production' }
    end

    trait :api_impot_particulier_activites_periscolaires_editeur do
      api_impot_particulier
      form_uid { 'api-impot-particulier-activites-periscolaires-editeur' }
    end

    trait :api_impot_particulier_cantine_scolaire_sandbox do
      api_impot_particulier
      form_uid { 'api-impot-particulier-cantine-scolaire-sandbox' }
    end

    trait :api_impot_particulier_cantine_scolaire_production do
      api_impot_particulier
      form_uid { 'api-impot-particulier-cantine-scolaire-production' }
    end

    trait :api_impot_particulier_cantine_scolaire_editeur do
      api_impot_particulier
      form_uid { 'api-impot-particulier-cantine-scolaire-editeur' }
    end

    trait :api_impot_particulier_aides_sociales_facultatives_sandbox do
      api_impot_particulier
      form_uid { 'api-impot-particulier-aides-sociales-facultatives-sandbox' }
    end

    trait :api_impot_particulier_aides_sociales_facultatives_production do
      api_impot_particulier
      form_uid { 'api-impot-particulier-aides-sociales-facultatives-production' }
    end

    trait :api_impot_particulier_aides_sociales_facultatives_editeur do
      api_impot_particulier
      form_uid { 'api-impot-particulier-aides-sociales-facultatives-editeur' }
    end

    trait :api_impot_particulier_carte_transport_sandbox do
      api_impot_particulier
      form_uid { 'api-impot-particulier-carte-transport-sandbox' }
    end

    trait :api_impot_particulier_carte_transport_production do
      api_impot_particulier
      form_uid { 'api-impot-particulier-carte-transport-production' }
    end

    trait :api_impot_particulier_carte_transport_editeur do
      api_impot_particulier
      form_uid { 'api-impot-particulier-carte-transport-editeur' }
    end

    trait :api_sfip_common do
      transient do
        skip_scopes_build { false }
      end

      after(:build) do |authorization_request, evaluator|
        authorization_request.scopes << 'dgfip_annee_n_moins_1' if !evaluator.skip_scopes_build && authorization_request.scopes.empty?
      end

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_sfip_sandbox do
      api_sfip_common

      type { 'AuthorizationRequest::APISFiPSandbox' }

      form_uid { 'api-sfip-sandbox' }
    end

    trait :api_sfip_production do
      api_sfip_common

      type { 'AuthorizationRequest::APISFiP' }

      form_uid { 'api-sfip-production' }

      has_previous_authorization_validated

      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_sfip_editeur do
      api_sfip_production
      form_uid { 'api-sfip-editeur' }
    end

    trait :api_sfip_stationnement_residentiel_sandbox do
      api_sfip_sandbox
      form_uid { 'api-sfip-stationnement-residentiel-sandbox' }
    end

    trait :api_sfip_stationnement_residentiel_production do
      api_sfip_production
      form_uid { 'api-sfip-stationnement-residentiel-production' }
    end

    trait :api_sfip_stationnement_residentiel_editeur do
      api_sfip_production
      form_uid { 'api-sfip-stationnement-residentiel-editeur' }
    end

    trait :api_sfip_place_creche_sandbox do
      api_sfip_sandbox
      form_uid { 'api-sfip-place-creche-sandbox' }
    end

    trait :api_sfip_place_creche_production do
      api_sfip_production
      form_uid { 'api-sfip-place-creche-production' }
    end

    trait :api_sfip_place_creche_editeur do
      api_sfip_production
      form_uid { 'api-sfip-place-creche-editeur' }
    end

    trait :api_sfip_activites_periscolaires_sandbox do
      api_sfip_sandbox
      form_uid { 'api-sfip-activites-periscolaires-sandbox' }
    end

    trait :api_sfip_activites_periscolaires_production do
      api_sfip_production
      form_uid { 'api-sfip-activites-periscolaires-production' }
    end

    trait :api_sfip_activites_periscolaires_editeur do
      api_sfip_production
      form_uid { 'api-sfip-activites-periscolaires-editeur' }
    end

    trait :api_sfip_cantine_scolaire_sandbox do
      api_sfip_sandbox
      form_uid { 'api-sfip-cantine-scolaire-sandbox' }
    end

    trait :api_sfip_cantine_scolaire_production do
      api_sfip_production
      form_uid { 'api-sfip-cantine-scolaire-production' }
    end

    trait :api_sfip_cantine_scolaire_editeur do
      api_sfip_production
      form_uid { 'api-sfip-cantine-scolaire-editeur' }
    end

    trait :api_sfip_aides_sociales_facultatives_sandbox do
      api_sfip_sandbox
      form_uid { 'api-sfip-aides-sociales-facultatives-sandbox' }
    end

    trait :api_sfip_aides_sociales_facultatives_production do
      api_sfip_production
      form_uid { 'api-sfip-aides-sociales-facultatives-production' }
    end

    trait :api_sfip_aides_sociales_facultatives_editeur do
      api_sfip_production
      form_uid { 'api-sfip-aides-sociales-facultatives-editeur' }
    end

    trait :api_sfip_carte_transport_sandbox do
      api_sfip_sandbox
      form_uid { 'api-sfip-carte-transport-sandbox' }
    end

    trait :api_sfip_carte_transport_production do
      api_sfip_production
      form_uid { 'api-sfip-carte-transport-production' }
    end

    trait :api_sfip_carte_transport_editeur do
      api_sfip_production
      form_uid { 'api-sfip-carte-transport-editeur' }
    end

    trait :api_pro_sante_connect do
      type { 'AuthorizationRequest::APIProSanteConnect' }

      form_uid { 'api-pro-sante-connect' }
      with_basic_infos
      with_cadre_juridique
      with_scopes
    end

    %w[
      annuaire-des-entreprises-marches-publics
      annuaire-des-entreprises-aides-publiques
      annuaire-des-entreprises-lutte-contre-la-fraude
      annuaire-des-entreprises-subventions-associations
    ].each do |form_uid|
      trait form_uid.tr('-', '_') do
        type { 'AuthorizationRequest::AnnuaireDesEntreprises' }

        form_uid { form_uid }

        with_basic_infos
        with_cadre_juridique
      end
    end

    %w[
      api-droits-cnam
      api-droits-cnam-etablissement-de-soin
      api-droits-cnam-organisme-complementaire
    ].each do |form_uid|
      trait form_uid.tr('-', '_') do
        type { 'AuthorizationRequest::APIDroitsCNAM' }

        form_uid { 'api-droits-cnam' }

        with_basic_infos
        with_personal_data
        with_cadre_juridique
        with_france_connect
      end
    end

    trait :api_indemnites_journalieres_cnam do
      type { 'AuthorizationRequest::APIIndemnitesJournalieresCNAM' }

      form_uid { 'api-indemnites-journalieres-cnam' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_france_connect
    end

    trait :api_declaration_auto_entrepreneur do
      type { 'AuthorizationRequest::APIDeclarationAutoEntrepreneur' }

      form_uid { 'api-declaration-auto-entrepreneur' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
      with_attestation_fiscale
    end

    trait :api_declaration_cesu do
      type { 'AuthorizationRequest::APIDeclarationCESU' }

      form_uid { 'api-declaration-cesu' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
      with_attestation_fiscale
    end

    trait :api_impot_particulier_sandbox do
      type { 'AuthorizationRequest::APIImpotParticulierSandbox' }

      form_uid { 'api-impot-particulier-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_modalities
      with_scopes
    end

    trait :france_connect do
      type { 'AuthorizationRequest::FranceConnect' }

      form_uid { 'france-connect' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_france_connect_eidas
      with_scopes
    end

    trait :france_connect_collectivite_administration do
      form_uid { 'france-connect-collectivite-administration' }

      france_connect
    end

    trait :france_connect_collectivite_epermis do
      form_uid { 'france-connect-collectivite-epermis' }

      france_connect
    end

    trait :france_connect_sante do
      form_uid { 'france-connect-sante' }

      france_connect
    end

    trait :formulaire_qf do
      type { 'AuthorizationRequest::FormulaireQF' }

      form_uid { 'formulaire-qf' }

      with_cadre_juridique
      with_personal_data
    end

    trait :api_hermes_sandbox do
      type { 'AuthorizationRequest::APIHermesSandbox' }

      form_uid { 'api-hermes-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_hermes_production do
      type { 'AuthorizationRequest::APIHermes' }

      form_uid { 'api-hermes-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_operational_acceptance
      with_safety_certification
      with_volumetrie
    end

    trait :api_e_contacts_sandbox do
      type { 'AuthorizationRequest::APIEContactsSandbox' }

      form_uid { 'api-e-contacts-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_e_contacts_production do
      type { 'AuthorizationRequest::APIEContacts' }

      form_uid { 'api-e-contacts-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_opale_sandbox do
      type { 'AuthorizationRequest::APIOpaleSandbox' }

      form_uid { 'api-opale-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_opale_production do
      type { 'AuthorizationRequest::APIOpale' }

      form_uid { 'api-opale-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_ocfi_sandbox do
      type { 'AuthorizationRequest::APIOcfiSandbox' }

      form_uid { 'api-ocfi-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_ocfi_production do
      type { 'AuthorizationRequest::APIOcfi' }

      form_uid { 'api-ocfi-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_e_pro_sandbox do
      type { 'AuthorizationRequest::APIEProSandbox' }

      form_uid { 'api-e-pro-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_e_pro_production do
      type { 'AuthorizationRequest::APIEPro' }

      form_uid { 'api-e-pro-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_robf_sandbox do
      type { 'AuthorizationRequest::APIRobfSandbox' }

      form_uid { 'api-robf-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_robf_production do
      type { 'AuthorizationRequest::APIRobf' }

      form_uid { 'api-robf-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_cpr_pro_adelie_sandbox do
      type { 'AuthorizationRequest::APICprProAdelieSandbox' }

      form_uid { 'api-cpr-pro-adelie-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_cpr_pro_adelie_production do
      type { 'AuthorizationRequest::APICprProAdelie' }

      form_uid { 'api-cpr-pro-adelie-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_imprimfip_sandbox do
      type { 'AuthorizationRequest::APIImprimfipSandbox' }

      form_uid { 'api-imprimfip-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_imprimfip_production do
      type { 'AuthorizationRequest::APIImprimfip' }

      form_uid { 'api-imprimfip-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_satelit_sandbox do
      type { 'AuthorizationRequest::APISatelitSandbox' }

      form_uid { 'api-satelit-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_satelit_production do
      type { 'AuthorizationRequest::APISatelit' }

      form_uid { 'api-satelit-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_mire_sandbox do
      type { 'AuthorizationRequest::APIMireSandbox' }

      form_uid { 'api-mire-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_mire_production do
      type { 'AuthorizationRequest::APIMire' }

      form_uid { 'api-mire-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_ensu_documents_sandbox do
      type { 'AuthorizationRequest::APIENSUDocumentsSandbox' }

      form_uid { 'api-ensu-documents-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_ensu_documents_production do
      type { 'AuthorizationRequest::APIENSUDocuments' }

      form_uid { 'api-ensu-documents-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_rial_sandbox do
      type { 'AuthorizationRequest::APIRialSandbox' }

      form_uid { 'api-rial-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_rial_production do
      type { 'AuthorizationRequest::APIRial' }

      form_uid { 'api-rial-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_infinoe_sandbox do
      type { 'AuthorizationRequest::APIINFINOESandbox' }

      form_uid { 'api-infinoe-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_infinoe_production do
      type { 'AuthorizationRequest::APIINFINOE' }

      form_uid { 'api-infinoe-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_infinoe_production_editeur do
      api_infinoe_production
      form_uid { 'api-infinoe-production-editeur' }
    end

    trait :api_infinoe_envoi_automatise_ecritures_sandbox do
      api_infinoe_sandbox
      form_uid { 'api-infinoe-envoi-automatise-ecritures-sandbox' }
    end

    trait :api_infinoe_envoi_automatise_ecritures_production do
      api_infinoe_production
      form_uid { 'api-infinoe-envoi-automatise-ecritures-production' }
    end

    trait :api_infinoe_envoi_automatise_ecritures_production_editeur do
      api_infinoe_production
      form_uid { 'api-infinoe-envoi-automatise-ecritures-production-editeur' }
    end

    trait :api_ficoba_sandbox do
      type { 'AuthorizationRequest::APIFicobaSandbox' }

      form_uid { 'api-ficoba-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_modalities
      with_scopes
    end

    trait :api_ficoba_production do
      type { 'AuthorizationRequest::APIFicoba' }

      form_uid { 'api-ficoba-production' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_modalities
      with_scopes
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end

    trait :api_ficoba_production_editeur do
      api_ficoba_production

      form_uid { 'api-ficoba-production-editeur' }
    end

    trait :api_scolarite do
      type { 'AuthorizationRequest::APIScolarite' }

      form_uid { 'api-scolarite' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
    end
  end

  trait :api_r2p_sandbox do
    type { 'AuthorizationRequest::APIR2PSandbox' }

    form_uid { 'api-r2p-sandbox' }

    with_basic_infos
    with_personal_data
    with_cadre_juridique
    with_modalities
  end

  trait :api_r2p_production do
    type { 'AuthorizationRequest::APIR2P' }

    form_uid { 'api-r2p-production' }

    has_previous_authorization_validated

    with_basic_infos
    with_personal_data
    with_cadre_juridique
    with_modalities
    with_safety_certification
    with_operational_acceptance
    with_volumetrie
  end

  trait :api_r2p_ordonnateur_sandbox do
    api_r2p_sandbox
    form_uid { 'api-r2p-ordonnateur-sandbox' }
  end

  trait :api_r2p_ordonnateur_production do
    api_r2p_production
    form_uid { 'api-r2p-ordonnateur-production' }
  end

  trait :api_r2p_appel_spi_sandbox do
    api_r2p_sandbox
    form_uid { 'api-r2p-appel-spi-sandbox' }
  end

  trait :api_r2p_appel_spi_production do
    api_r2p_production
    form_uid { 'api-r2p-appel-spi-production' }
  end

  trait :api_r2p_ordonnateur_production_editeur do
    api_r2p_production
    form_uid { 'api-r2p-ordonnateur-production-editeur' }
  end

  trait :api_r2p_appel_spi_production_editeur do
    api_r2p_production
    form_uid { 'api-r2p-appel-spi-production-editeur' }
  end

  trait :api_r2p_production_editeur do
    api_r2p_production
    form_uid { 'api-r2p-production-editeur' }
  end

  trait :pro_connect_service_provider do
    type { 'AuthorizationRequest::ProConnectServiceProvider' }

    form_uid { 'pro-connect-fs' }

    with_basic_infos
    with_personal_data
    with_cadre_juridique
    with_modalities
    with_scopes
  end

  trait :pro_connect_fs do
    pro_connect_service_provider
  end

  trait :pro_connect_identity_provider do
    pro_connect_service_provider

    type { 'AuthorizationRequest::ProConnectIdentityProvider' }
    form_uid { 'pro-connect-fi' }
  end

  trait :pro_connect_fi do
    pro_connect_identity_provider
  end

  trait :api_ingres do
    type { 'AuthorizationRequest::APIIngres' }

    form_uid { 'api-ingres' }

    with_basic_infos
    with_personal_data
    with_cadre_juridique
  end

  trait :le_taxi do
    type { 'AuthorizationRequest::LeTaxi' }

    form_uid { 'le-taxi' }

    with_basic_infos
    with_technical_team
    with_personal_data
  end

  %w[
    le-taxi-chauffeur
    le-taxi-client
    le-taxi-client-chauffeur
  ].each do |form_uid|
    trait form_uid.tr('-', '_') do
      le_taxi
      form_uid { form_uid }
    end
  end

  trait :api_mobilic do
    type { 'AuthorizationRequest::APIMobilic' }

    form_uid { 'api-mobilic' }

    with_basic_infos
    with_personal_data
  end
end
