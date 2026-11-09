module ApplicationHelper
  include Dsfr::Stepper
  include Dsfr::Accordion
  include Dsfr::Modal
  include Dsfr::Pictogram
  include SkipLinks
  include UserRightsPathsHelper

  def obfuscate(text)
    stars = '*' * (text.length - 5)
    "#{stars}#{text[-5..]}"
  end

  def simple_format_without_html_tags(text, html_options = {}, options = {})
    simple_format(text, html_options, { sanitize_options: { tags: [], attributes: [] } }.merge(options))
  end

  def linkify_urls(text)
    return '' if text.blank?

    auto_link(h(text), link: :urls, html: { target: '_blank', rel: 'noopener noreferrer' }, sanitize: false).html_safe
  end

  def provider_logo_image_tag(authorization_definition, options = {})
    return nil unless authorization_definition.provider
    return nil unless authorization_definition.provider.logo.attached?

    options = options.merge(alt: "#{authorization_definition.provider.name}, fournisseur de données")
    image_tag(authorization_definition.provider.logo, options)
  end

  def displays_provider_logo?
    @authorization_definition.present? && @display_provider_logo_in_header # rubocop:disable Rails/HelperInstanceVariable
  end

  def public_header?
    !user_signed_in? && !registered_subdomain?
  end

  def european_wallet_registry_open?
    FeatureFlag.enabled?(:european_wallet_registry_open)
  end

  def european_wallet_public_registry_path
    european_wallet_page_path(anchor: 'registre-public')
  end

  def european_wallet_registration_policy_path
    european_wallet_page_path(anchor: 'questions')
  end

  def european_wallet_registration_path
    european_wallet_page_path(anchor: 'etapes')
  end

  def european_wallet_notify_path
    european_wallet_page_path(anchor: 'etre-prevenu')
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
    authorization_request.definition.france_connect? &&
      authorization_request.france_connected_authorizations.exists?
  end
end
