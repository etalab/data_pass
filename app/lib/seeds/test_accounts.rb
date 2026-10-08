class Seeds::TestAccounts < Seeds
  ACCOUNTS = {
    'reporter-apie@yopmail.com' => { organization: :dinum, roles: %w[dinum:api_entreprise:reporter] },
    'reporter-fd-menj@yopmail.com' => { organization: :menj, roles: %w[menj:*:reporter] },
    'instructeur-apie@yopmail.com' => { organization: :dinum, roles: %w[dinum:api_entreprise:instructor] },
    'instructeur-dgfip@yopmail.com' => { organization: :dgfip, roles: %w[dgfip:api_impot_particulier:instructor dgfip:api_impot_particulier_sandbox:instructor] },
    'instructeur-multi-fd@yopmail.com' => { organization: :dinum, roles: %w[dinum:api_particulier:instructor cnam:api_droits_cnam:instructor] },
    'instructeur-sans-perimetre@yopmail.com' => { organization: :mtes, roles: %w[mtes:api_gunenv:instructor] },
    'manager-apie@yopmail.com' => { organization: :dinum, roles: %w[dinum:api_entreprise:manager] },
    'manager-fd-dgfip@yopmail.com' => { organization: :dgfip, roles: %w[dgfip:*:manager] },
    'dev-apie@yopmail.com' => { organization: :dinum, roles: %w[dinum:api_entreprise:developer] },
    'dev-apip@yopmail.com' => { organization: :dinum, roles: %w[dinum:api_particulier:developer] },
    'dev-manager-dgfip@yopmail.com' => { organization: :dgfip, roles: %w[dgfip:*:developer dgfip:*:manager] },
    'admin@yopmail.com' => { organization: :dinum, roles: %w[admin] },
    'interne-sans-droit@yopmail.com' => { organization: :dinum, roles: [] },
  }.freeze

  PROFILES = {
    'reporter-apie@yopmail.com' => { given_name: 'Camille', family_name: 'Reporter APIE', job_title: 'Chargée de suivi API Entreprise', phone_number: '0199000101' },
    'reporter-fd-menj@yopmail.com' => { given_name: 'Hugo', family_name: 'Reporter MENJ', job_title: 'Chargé de suivi des habilitations MENJ', phone_number: '0199000102' },
    'instructeur-apie@yopmail.com' => { given_name: 'Léa', family_name: 'Instructrice APIE', job_title: 'Instructrice API Entreprise', phone_number: '0199000103' },
    'instructeur-dgfip@yopmail.com' => { given_name: 'Thomas', family_name: 'Instructeur DGFiP', job_title: 'Instructeur API Impôt particulier', phone_number: '0199000104' },
    'instructeur-multi-fd@yopmail.com' => { given_name: 'Inès', family_name: 'Instructrice multi-FD', job_title: 'Instructrice API Particulier et API Droits CNAM', phone_number: '0199000105' },
    'instructeur-sans-perimetre@yopmail.com' => { given_name: 'Karim', family_name: 'Instructeur sans périmètre', job_title: 'Instructeur sans demande à instruire', phone_number: '0199000106' },
    'manager-apie@yopmail.com' => { given_name: 'Sophie', family_name: 'Manager APIE', job_title: 'Responsable des habilitations API Entreprise', phone_number: '0199000107' },
    'manager-fd-dgfip@yopmail.com' => { given_name: 'Paul', family_name: 'Manager DGFiP', job_title: 'Responsable des habilitations DGFiP', phone_number: '0199000108' },
    'dev-apie@yopmail.com' => { given_name: 'Nora', family_name: 'Dev APIE', job_title: 'Développeuse API Entreprise', phone_number: '0199000109' },
    'dev-apip@yopmail.com' => { given_name: 'Sacha', family_name: 'Dev APIP', job_title: 'Développeur API Particulier', phone_number: '0199000122' },
    'dev-manager-dgfip@yopmail.com' => { given_name: 'Julien', family_name: 'Dev manager DGFiP', job_title: 'Développeur et responsable des habilitations DGFiP', phone_number: '0199000110' },
    'admin@yopmail.com' => { given_name: 'Alice', family_name: 'Admin', job_title: 'Administratrice DataPass', phone_number: '0199000111' },
    'admin-instructeur@yopmail.com' => { given_name: 'Marc', family_name: 'Admin instructeur', job_title: 'Administrateur et instructeur DataPass', phone_number: '0199000112' },
    'interne-sans-droit@yopmail.com' => { given_name: 'Chloé', family_name: 'Interne sans droit', job_title: 'Agente DINUM sans rôle', phone_number: '0199000113' },
    'dem-commune@yopmail.com' => { given_name: 'Yasmine', family_name: 'Demandeuse commune', job_title: 'Chargée de mission numérique', phone_number: '0199000119' },
    'dem-departement@yopmail.com' => { given_name: 'Antoine', family_name: 'Demandeur département', job_title: 'Chargé de l’action sociale', phone_number: '0199000120' },
    'dem-editeur@yopmail.com' => { given_name: 'Manon', family_name: 'Demandeuse éditeur', job_title: 'Cheffe de projet intégration', phone_number: '0199000121' },
    'dem-org-non-verifiee@yopmail.com' => { given_name: 'Lucas', family_name: 'Demandeur org non vérifiée', job_title: 'Chargé de mission', phone_number: '0199000114' },
    'dem-multi-orga@yopmail.com' => { given_name: 'Emma', family_name: 'Demandeuse multi-orga', job_title: 'Chargée de mission', phone_number: '0199000115' },
    'dem-orga-fermee@yopmail.com' => { given_name: 'Louis', family_name: 'Demandeur orga fermée', job_title: 'Chargé de mission', phone_number: '0199000116' },
    'dem-banni@yopmail.com' => { given_name: 'Jade', family_name: 'Demandeuse bannie', job_title: 'Chargée de mission', phone_number: '0199000117' },
    'dem-email-ko@yopmail.com' => { given_name: 'Noé', family_name: 'Demandeur email KO', job_title: 'Chargé de mission', phone_number: '0199000118' },
    'dem-historique@yopmail.com' => { given_name: 'Lina', family_name: 'Demandeuse historique', job_title: 'Chargée de mission, demandes historiques', phone_number: '0199000124' },
    'dem-stats@yopmail.com' => { given_name: 'Robin', family_name: 'Demandeur statistiques', job_title: 'Compte des statistiques, à ne pas utiliser en recette', phone_number: '0199000123' },
  }.freeze

  STATS_COMMUNES_COUNT = 4

  def initialize(seeds)
    @seeds = seeds
  end

  def perform
    accounts.each do |email, account|
      create_account(email, **account)
    end

    create_reference_applicants
    create_applicants_in_a_particular_state
    create_stats_applicant
  end

  private

  def accounts
    ACCOUNTS.merge(
      'admin-instructeur@yopmail.com' => { organization: :dinum, roles: ['admin'] + @seeds.all_authorization_definition_manager_roles }
    )
  end

  def create_account(email, organization:, roles:)
    create_user(email, roles:).add_to_organization(organizations.fetch(organization), current: true, **verified_link)
  end

  def create_reference_applicants
    create_clamart_applicant('dem-commune@yopmail.com')
    create_clamart_applicant('dem-historique@yopmail.com')
    create_user('dem-departement@yopmail.com').add_to_organization(@seeds.rhone_departement_organization, current: true, **verified_link)
    create_user('dem-editeur@yopmail.com').add_to_organization(organizations.fetch(:editor), current: true, **verified_link)
  end

  def create_applicants_in_a_particular_state
    create_user('dem-org-non-verifiee@yopmail.com').add_to_organization(@seeds.dinum_organization, current: true, verified: false)
    create_applicant_with_several_organizations
    create_user('dem-orga-fermee@yopmail.com').add_to_organization(organizations.fetch(:closed), current: true, **verified_link)
    create_user('dem-vierge@yopmail.com')
    create_clamart_applicant('dem-banni@yopmail.com', banned_at: Time.zone.now, ban_reason: 'Compte de test banni')
    create_clamart_applicant('dem-email-ko@yopmail.com')
    create_verified_email('dem-email-ko@yopmail.com', 'undeliverable')
  end

  def create_applicant_with_several_organizations
    applicant = create_user('dem-multi-orga@yopmail.com')

    applicant.add_to_organization(@seeds.dinum_organization, verified: false)
    applicant.add_to_organization(@seeds.clamart_organization, current: true, **verified_link)
  end

  def create_stats_applicant
    applicant = create_user('dem-stats@yopmail.com')

    STATS_COMMUNES_COUNT.times do |index|
      applicant.add_to_organization(create_stats_commune("COMMUNE DE STATISTIQUES #{index + 1}"), current: index.zero?, **verified_link)
    end
  end

  def create_stats_commune(name)
    siret = Faker::Company.french_siret_number

    Organization.create!(
      legal_entity_id: siret,
      last_mon_compte_pro_updated_at: DateTime.now,
      mon_compte_pro_payload: { label: name },
      insee_payload: stats_commune_insee_payload(siret, name),
      last_insee_payload_updated_at: DateTime.now,
    )
  end

  def stats_commune_insee_payload(siret, name)
    payload = JSON.parse(Rails.root.join('spec/fixtures/insee/21920023500014.json').read)
    payload['etablissement'].merge!('siret' => siret, 'siren' => siret.first(9), 'nic' => siret.last(5))
    payload['etablissement']['uniteLegale']['denominationUniteLegale'] = name
    payload
  end

  def create_clamart_applicant(email, **attributes)
    create_user(email, **attributes).add_to_organization(@seeds.clamart_organization, current: true, **verified_link)
  end

  def create_user(email, **attributes)
    User.create!(email:, **PROFILES.fetch(email, {}), **attributes)
  end

  def verified_link
    {
      verified: true,
      identity_federator: 'pro_connect',
      identity_provider_uid: IdentityProvider::PRO_CONNECT_IDENTITY_PROVIDER_UID,
    }
  end

  def organizations
    @organizations ||= {
      dinum: @seeds.dinum_organization,
      dgfip: create_organization(siret: '13000495500014', name: 'DGFIP'),
      menj: create_organization(siret: '11004301500012', name: 'Ministère de l’Éducation nationale'),
      mtes: create_organization(siret: '11006801200050', name: 'Ministère de la Transition écologique'),
      closed: create_organization(siret: '13002437500011', name: 'Secrétariat d’État chargé de l’Éducation prioritaire'),
      editor: create_organization(siret: '32816124500027', name: 'MGDIS'),
    }
  end
end
