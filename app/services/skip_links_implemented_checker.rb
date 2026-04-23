class SkipLinksImplementedChecker
  attr_reader :controller_name, :action_name, :has_skip_links

  WHITELISTED_ROUTES = %w[
    archive_authorization_requests#new
    authorizations#show
    authorizations#index
    authorization_definitions#index
    authorization_requests#index
    authorization_requests#show
    authorization_requests#new
    authorization_request_forms#new
    authorization_request_forms#show
    authorization_request_forms#create
    authorization_request_forms#update
    authorization_request_forms#start
    authorization_request_forms#summary
    authorization_request_forms/build#show
    authorization_request_forms/build#update
    authorization_requests/blocks#edit
    authorization_requests/blocks#update
    cancel_authorization_reopenings#new
    cancel_next_authorization_request_stage#new
    claim_instructor_draft_requests#show
    claim_instructor_draft_requests#create

    authorization_request_events#index
    messages#index
    profile#edit

    organizations#show
    organizations#new
    organizations#create

    stats#index
    pages#home
    pages#accessibilite
    pages#politique_confidentialite
    pages#faq
    pages#mentions_legales
    pages#cgu_api_impot_particulier_bas
    pages#cgu_api_impot_particulier_prod

    instruction/authorization_requests#index
    instruction/authorization_requests#show
    instruction/approve_authorization_requests#new
    instruction/approve_authorization_requests#create
    instruction/refuse_authorization_requests#new
    instruction/refuse_authorization_requests#create
    instruction/archive_authorization_requests#new
    instruction/archive_authorization_requests#create
    instruction/request_changes_on_authorization_requests#new
    instruction/request_changes_on_authorization_requests#create
    instruction/authorization_request_events#index
    instruction/authorizations#index
    instruction/france_connected_authorizations#index
    instruction/transfer_authorization_requests#new
    instruction/transfer_authorization_requests#create
    instruction/messages#index
    instruction/cancel_authorization_reopenings#new
    instruction/cancel_authorization_reopenings#create
    instruction/cancel_next_authorization_request_stages#new
    instruction/cancel_next_authorization_request_stages#create
    instruction/revoke_authorization_requests#new
    instruction/revoke_authorization_requests#create
    instruction/revoke_authorizations#new
    instruction/revoke_authorizations#create
    instruction/instructor_draft_requests/invite#new
    instruction/instructor_draft_requests/invite#create
    instruction/instructor_draft_requests#index
    instruction/instructor_draft_requests#new
    instruction/instructor_draft_requests#start
    instruction/instructor_draft_requests#edit
    instruction/instructor_draft_requests#update
    instruction/message_templates#new
    instruction/message_templates#create
    instruction/message_templates#edit
    instruction/message_templates#update
    instruction/message_templates#destroy
    instruction/message_templates#preview

    admin#index
    admin/users_with_roles#index
    admin/whitelisted_verified_emails#index
    admin/impersonate#new
    admin/impersonate#create
    admin/users_with_roles#index
    admin/users_with_roles#edit
    admin/users_with_roles#new
    admin/users_with_roles#create
    admin/whitelisted_verified_emails#index
    admin/whitelisted_verified_emails#new
    admin/transfer_authorization_requests#new
    admin/transfer_authorization_requests#create
    admin/user_organization_verifications#index
    admin/mark_user_organization_as_verified#new
    admin/mark_user_organization_as_verified#create
    admin/mark_user_organization_as_verified#edit
    admin/mark_user_organization_as_verified#update
    admin/unmark_user_organization_as_verified#destroy
    admin/data_providers#index
    admin/data_providers#new
    admin/data_providers#create
    admin/data_providers#edit
    admin/data_providers#update

    admin/bans#index
    admin/bans#new
    admin/bans#create
    admin/bans#destroy
    admin/bans#confirm_destroy

    developers/open_api#show
    developers/oauth_applications#index
    developers/tutorials#index
    developers/tutorials#show
    pages#proconnect_connexion
    public/authorization_requests#show

    manual_transfer_authorization_requests#new
    next_authorization_request_stage#new
    reopen_authorizations#new
    transfer_authorization_requests#new
    transfer_authorization_requests#create
  ].freeze

  def initialize(controller_name:, action_name:, has_skip_links: false)
    @controller_name = controller_name
    @action_name = action_name
    @has_skip_links = has_skip_links
  end

  def perform!
    return true if has_skip_links
    return true if whitelisted?

    current_route = "#{controller_name}##{action_name}"
    raise SkipLinksNotDefinedError, <<~MSG.strip
      Accessibility Error: No skip links have been defined for the current page (#{current_route}).

      Two ways to fix this, depending on your use case:

      1. Standard case (default skip links: Contenu / Menu / Pied de page):
         Add `#{current_route}` to SkipLinksImplementedChecker::WHITELISTED_ROUTES.
         The default skip links from `SkipLinks#default_skip_links` will be rendered.
         To customize the « Aller au contenu » label, set `content_for(:content_skip_link_text)` in your view.

      2. Specific case (custom anchors, tabs, business-specific navigation):
         Define `content_for(:skip_links)` in your view with your own `skip_link(...)` calls.

      Prefer option 1 unless you actually need custom anchors.
    MSG
  end

  private

  def whitelisted?
    WHITELISTED_ROUTES.include?("#{controller_name}##{action_name}")
  end

  class SkipLinksNotDefinedError < StandardError; end
end
