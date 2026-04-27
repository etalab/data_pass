class TitleDefinedChecker
  attr_reader :controller_name, :action_name, :has_title

  WHITELISTED_ROUTES = %w[
    archive_authorization_requests#new
    authorization_request_forms#new
    authorization_requests#new
    cancel_authorization_reopenings#new
    cancel_next_authorization_request_stage#new
    claim_instructor_draft_requests#show
    developers/oauth_applications#index
    developers/webhook_attempts#index
    developers/webhook_attempts#show
    developers/webhooks#edit
    developers/webhooks#enable
    developers/webhooks#index
    developers/webhooks#new
    developers/webhooks#show_secret
    instruction/approve_authorization_requests#new
    instruction/archive_authorization_requests#new
    instruction/cancel_authorization_reopenings#create
    instruction/cancel_authorization_reopenings#new
    instruction/cancel_next_authorization_request_stages#new
    instruction/instructor_draft_requests/invite#create
    instruction/instructor_draft_requests/invite#new
    instruction/message_templates#create
    instruction/message_templates#edit
    instruction/message_templates#index
    instruction/message_templates#new
    instruction/refuse_authorization_requests#create
    instruction/refuse_authorization_requests#new
    instruction/request_changes_on_authorization_requests#create
    instruction/request_changes_on_authorization_requests#new
    instruction/revoke_authorization_requests#new
    instruction/revoke_authorizations#new
    instruction/transfer_authorization_requests#create
    instruction/transfer_authorization_requests#new
    manual_transfer_authorization_requests#new
    organizations#create
    organizations#new
    organizations#show
    reopen_authorizations#new
    transfer_authorization_requests#create
    transfer_authorization_requests#new
  ].freeze

  def initialize(controller_name:, action_name:, has_title: false)
    @controller_name = controller_name
    @action_name = action_name
    @has_title = has_title
  end

  def perform!
    return true if has_title
    return true if whitelisted?

    current_route = "#{controller_name}##{action_name}"
    raise TitleNotDefinedError, <<~MSG.strip
      Accessibility/SEO Error: No page title has been defined for the current page (#{current_route}).

      Two ways to fix this:

      1. Standard case (nearly every page):
         Add `<% set_title! t('page_titles.<key>') %>` at the top of your view.
         Declare the i18n key in `config/locales/page_titles.fr.yml`.

      2. Exception (layout-rendered page with intentional default title):
         Add `#{current_route}` to TitleDefinedChecker::WHITELISTED_ROUTES.

      Prefer option 1 unless the page is explicitly title-less.
    MSG
  end

  private

  def whitelisted?
    WHITELISTED_ROUTES.include?("#{controller_name}##{action_name}")
  end

  class TitleNotDefinedError < StandardError; end
end
