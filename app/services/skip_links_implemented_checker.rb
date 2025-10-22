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

    messages#index
    profile#edit

    organizations#show
    organizations#new
    organizations#create

    stats#index
    pages#home
    pages#accessibilite
    pages#faq

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
    instruction/revoke_authorization_requests#new
    instruction/revoke_authorization_requests#create

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

    open_api#show
    oauth_applications#index
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
    raise SkipLinksNotDefinedError, "Accessibility Error: No skip links have been defined for the current page (#{current_route}). To ensure proper navigation for keyboard and screen reader users, add skip links by using `content_for(:skip_links)` in your view or defining them through a dedicated helper method."
  end

  private

  def whitelisted?
    WHITELISTED_ROUTES.include?("#{controller_name}##{action_name}")
  end

  class SkipLinksNotDefinedError < StandardError; end
end
