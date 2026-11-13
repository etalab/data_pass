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

  def european_wallet_page_path
    root_path(anchor: 'portefeuille-europeen')
  end

  def european_wallet_phone_mockup(caption_id:)
    Molecules::PhoneMockupComponent.new(
      caption: { id: caption_id, text: t('shared.european_wallet_phone.caption') },
      header: european_wallet_phone_header,
      rows: european_wallet_phone_rows,
      status: t('shared.european_wallet_phone.registered'),
      actions: [t('shared.european_wallet_phone.refuse'), t('shared.european_wallet_phone.share')]
    )
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

  def european_wallet_phone_header
    {
      avatar: t('shared.european_wallet_phone.avatar'),
      title: t('shared.european_wallet_phone.organization'),
      subtitle: t('shared.european_wallet_phone.request')
    }
  end

  def european_wallet_phone_rows
    [
      { label: t('shared.european_wallet_phone.data_label'), value: t('shared.european_wallet_phone.data_value') },
      { label: t('shared.european_wallet_phone.purpose_label'), value: t('shared.european_wallet_phone.purpose_value') }
    ]
  end

  def france_connected_authorizations?(authorization_request)
    authorization_request.definition.france_connect? &&
      authorization_request.france_connected_authorizations.exists?
  end
end
