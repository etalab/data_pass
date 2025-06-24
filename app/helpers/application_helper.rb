module ApplicationHelper
  include DSFR::Stepper
  include DSFR::Accordion
  include DSFR::Modal
  include DSFR::Pictogram

  def obfuscate(text)
    stars = '*' * (text.length - 5)
    "#{stars}#{text[-5..]}"
  end

  def simple_format_without_html_tags(text, html_options = {}, options = {})
    simple_format(text, html_options, { sanitize_options: { tags: [], attributes: [] } }.merge(options))
  end

  def provider_logo_image_tag(authorization_definition, options = {})
    options = options.merge(alt: "Logo du fournisseur de données \" #{authorization_definition.provider.name}\"")
    image_tag("data_providers/#{authorization_definition.provider.logo}", options)
  end

  def displays_provider_logo?
    @authorization_definition.present? && @display_provider_logo_in_header # rubocop:disable Rails/HelperInstanceVariable
  end

  def latest_authorization_path(authorization_request)
    authorization_path(authorization_request.latest_authorization)
  end

  def instruction_tabs_for(authorization_request)
    tabs = {
      authorization_request: instruction_authorization_request_path(authorization_request),
      authorization_request_events: instruction_authorization_request_events_path(authorization_request),
    }

    tabs[:messages] = instruction_authorization_request_messages_path(authorization_request) if authorization_request.definition.feature?(:messaging)
    tabs[:authorizations] = instruction_authorization_request_authorizations_path(authorization_request) if authorization_request.authorizations.any?
    tabs[:france_connected_authorizations] = instruction_authorization_request_france_connected_authorizations_path(authorization_request) if france_connected_authorizations?(authorization_request)

    tabs
  end

  def skip_link(text, anchor)
    content_tag(:li) do
      link_to(text, "##{anchor}", class: 'fr-link')
    end
  end

  def default_skip_links
    [
      skip_link('Menu', 'header'),
      skip_link('Pied de page', 'footer')
    ].join.html_safe
  end

  def skip_links_content
    if content_for?(:skip_links)
      content_for(:skip_links)
    elsif Rails.env.test? && !whitelisted_for_default_skip_links?
      raise 'No skip links defined for this page. Use content_for(:skip_links) to define skip links or define them in a view-specific helper.'
    else
      default_skip_links
    end
  end

  def whitelisted_for_default_skip_links?
    whitelist = %w[
      authorizations#show
      authorization_requests#index
      authorization_requests#show
      authorization_requests#new
      authorization_requests#edit
      authorization_request_forms#new
      authorization_request_forms#start
      # authorization_request_forms#create
      authorization_request_forms#summary
      # build#show
      # build#update
      authorization_definitions#index
      instruction/authorization_requests#index
      instruction/authorization_requests#show
      instruction/authorizations#index
      instruction/france_connected_authorizations#index
      profile#edit
    ]

    whitelist.include?("#{controller_name}##{action_name}")
  end

  private

  def renders_html_view?
    request.format.html? && !request.xhr? && response.content_type&.include?('text/html')
  rescue StandardError
    respond_to?(:content_for?) && respond_to?(:render)
  end

  def france_connected_authorizations?(authorization_request)
    authorization_request.definition.id == 'france_connect' && authorization_request.france_connected_authorizations.exists?
  end
end
