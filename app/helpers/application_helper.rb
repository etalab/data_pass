module ApplicationHelper
  include DSFR::Stepper
  include DSFR::Accordion
  include DSFR::Modal
  include DSFR::Pictogram
  include SkipLinks

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

  private

  def france_connected_authorizations?(authorization_request)
    authorization_request.definition.id == 'france_connect' && authorization_request.france_connected_authorizations.exists?
  end
end
