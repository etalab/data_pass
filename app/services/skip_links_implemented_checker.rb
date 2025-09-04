class SkipLinksImplementedChecker
  attr_reader :controller_name, :action_name, :has_skip_links

  WHITELISTED_ROUTES = %w[
    admin#index
    admin/users_with_roles#index
    admin/whitelisted_verified_emails#index
    approve_authorization_requests#new
    archive_authorization_requests#new
    authorization_definitions#index
    authorization_request_events#index
    authorization_request_forms#create
    authorization_request_forms#new
    authorization_request_forms#show
    authorization_request_forms#start
    authorization_request_forms#summary
    authorization_request_forms#update
    authorization_request_forms/build#show
    authorization_requests#index
    authorization_requests#new
    authorization_requests#show
    authorizations#index
    authorizations#show
    blocks#edit
    blocks#index
    blocks#update
    build#show
    build#update
    cancel_authorization_reopenings#create
    cancel_authorization_reopenings#new
    cancel_next_authorization_request_stage#new
    impersonate#create
    impersonate#new
    instruction/authorization_requests#index
    instruction/authorization_requests#show
    instruction/authorizations#index
    instruction/france_connected_authorizations#index
    manual_transfer_authorization_requests#new
    messages#index
    next_authorization_request_stage#new
    oauth_applications#index
    open_api#show
    organizations#create
    organizations#new
    organizations#show
    pages#accessibilite
    pages#faq
    pages#home
    pages#proconnect_connexion
    profile#edit
    public/authorization_requests#show
    refuse_authorization_requests#create
    refuse_authorization_requests#new
    reopen_authorizations#new
    request_changes_on_authorization_requests#create
    request_changes_on_authorization_requests#new
    revoke_authorization_requests#new
    stats#index
    transfer_authorization_requests#create
    transfer_authorization_requests#new
    users_with_roles#create
    users_with_roles#edit
    users_with_roles#index
    users_with_roles#new
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
    raise SkipLinksNotDefinedError, "Accessibility Error: No skip links have been defined for the current page (#{current_route}). To ensure proper navigation for keyboard and screen reader users, add skip links by using `content_for(:skip_links)` in your view or defining them through a dedicated helper method."
  end

  private

  def whitelisted?
    WHITELISTED_ROUTES.include?("#{controller_name}##{action_name}")
  end

  class SkipLinksNotDefinedError < StandardError; end
end
