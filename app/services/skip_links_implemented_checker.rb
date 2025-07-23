class SkipLinksImplementedChecker
  attr_reader :controller_name, :action_name, :has_skip_links

  WHITELISTED_ROUTES = %w[
    archive_authorization_requests#new
    authorizations#show
    authorizations#index
    authorization_requests#index
    authorization_requests#show
    authorization_requests#new
    authorization_request_events#index
    authorization_request_forms#new
    authorization_request_forms#show
    authorization_request_forms#create
    authorization_request_forms#update
    authorization_request_forms#start
    authorization_request_forms#summary
    authorization_request_forms/build#show
    authorization_definitions#index
    approve_authorization_requests#new
    blocks#index
    blocks#edit
    blocks#update
    build#show
    build#update
    cancel_authorization_reopenings#new
    cancel_authorization_reopenings#create
    cancel_next_authorization_request_stage#new
    pages#home
    pages#accessibilite
    messages#index
    stats#index
    pages#faq
    impersonate#new
    impersonate#create
    instruction/authorization_requests#index
    instruction/authorization_requests#show
    instruction/authorizations#index
    instruction/france_connected_authorizations#index
    profile#edit
    admin#index
    admin/users_with_roles#index
    admin/whitelisted_verified_emails#index
    open_api#show
    oauth_applications#index
    pages#proconnect_connexion
    public/authorization_requests#show
    manual_transfer_authorization_requests#new
    next_authorization_request_stage#new
    request_changes_on_authorization_requests#new
    request_changes_on_authorization_requests#create
    reopen_authorizations#new
    refuse_authorization_requests#new
    transfer_authorization_requests#new
    transfer_authorization_requests#create
    refuse_authorization_requests#create
    revoke_authorization_requests#new
    users_with_roles#index
    users_with_roles#edit
    users_with_roles#new
    users_with_roles#create
    whitelisted_verified_emails#index
    whitelisted_verified_emails#new
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
    raise SkipLinksNotDefinedError, "No skip links defined for this page (#{current_route}). Use content_for(:skip_links) to define skip links or define them in a view-specific helper."
  end

  private

  def whitelisted?
    WHITELISTED_ROUTES.include?("#{controller_name}##{action_name}")
  end

  class SkipLinksNotDefinedError < StandardError; end
end
