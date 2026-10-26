class Seeds::OauthApplication
  API_ENTREPRISE_ACTIONS = %w[submission validation].freeze

  def initialize(context)
    @accounts = context.accounts
  end

  def perform
    create_api_entreprise_application
    create_multi_provider_application
  end

  private

  def create_api_entreprise_application
    application = Doorkeeper::Application.create!(
      name: 'API Entreprise',
      uid: 'client_id',
      secret: 'so_secret',
      owner: @accounts.find('dev-apie@yopmail.com'),
    )

    API_ENTREPRISE_ACTIONS.each { |action| grant_api_access(application, provider_slug('api_entreprise'), action) }
    make_applicant_and_instructor_emails_optional(provider_slug('api_entreprise'))
  end

  def make_applicant_and_instructor_emails_optional(slug)
    DataProvider.find_by!(slug:).update!(
      api_contract_options: { 'optional_notifications' => %w[applicant_submit_receipt instructors_new_request] },
    )
  end

  def create_multi_provider_application
    application = Doorkeeper::Application.create!(
      name: 'API Particulier et API Droits CNAM',
      uid: 'multi_provider_client_id',
      secret: 'multi_provider_secret',
      owner: @accounts.find('dev-multi-fd@yopmail.com'),
    )

    grant_api_access(application, provider_slug('api_particulier'), 'submission')
    revoke_api_access(grant_api_access(application, provider_slug('api_droits_cnam'), 'validation'))
  end

  def revoke_api_access(grant)
    Admin::RevokeAPIAccess.call!(
      admin:,
      grant:,
      reason: 'Retrait de démonstration : le fournisseur a changé son parcours',
    )
  end

  def grant_api_access(application, slug, action)
    Admin::GrantAPIAccess.call!(
      admin:,
      params: {
        oauth_application_id: application.id,
        data_provider_id: DataProvider.find_by!(slug:).id,
        action:,
        grant_reason: 'Droit accordé par les données de démonstration',
      },
    ).grant
  end

  def provider_slug(definition_id)
    AuthorizationDefinition.find(definition_id).provider_slug
  end

  def admin
    @admin ||= @accounts.find('admin-instructeur@yopmail.com')
  end
end
