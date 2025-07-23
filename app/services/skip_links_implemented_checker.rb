class SkipLinksImplemented
  attr_reader :controller_name, :action_name, :request_path, :has_skip_links

  WHITELISTED_ROUTES = %w[
    authorizations#show
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
    build#show
    build#update
    pages#home
    pages#accessibilite
    stats#index
    pages#faq
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
    public/authorization_requests#show
    request_changes_on_authorization_requests#new
  ].freeze

  def initialize(controller_name:, action_name:, has_skip_links: false)
    @controller_name = controller_name
    @action_name = action_name
    @has_skip_links = has_skip_links
  end

  def valid!
    return true if has_skip_links
    return true if whitelisted?

    current_route = "#{controller_name}##{action_name}"
    raise SkipLinksNotDefinedError, "No skip links defined for this page (#{current_route}). Use content_for(:skip_links) to define skip links or define them in a view-specific helper."
  end

  private

  def whitelisted?
    WHITELISTED_ROUTES.include?("#{controller_name}##{action_name}")
  end
end

class SkipLinksNotDefinedError < StandardError; end
