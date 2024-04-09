module ApplicationHelper
  include DSFR::Stepper
  include DSFR::Accordion
  include DSFR::Modal
  include DSFR::Pictogram

  def provider_logo_image_tag(authorization_definition, options = {})
    options = options.merge(alt: "Logo du fournisseur de données \" #{authorization_definition.provider.name}\"")
    image_tag("data_providers/#{authorization_definition.provider.logo}", options)
  end

  def displays_provider_logo?
    @authorization_definition.present? && @display_provider_logo_in_header # rubocop:disable Naming/HelperInstanceVariable
  end

  def authorization_request_status_badge(authorization_request, no_icon: false, scope: nil)
    content_tag(
      :span,
      t(authorization_request_status_badge_translation(authorization_request, scope)),
      class: [
        'fr-badge',
        no_icon ? 'fr-badge--no-icon' : nil,
      ]
        .concat(authorization_request_status_badge_class(authorization_request))
        .compact,
    )
  end

  def authorization_request_status_badge_class(authorization_request)
    case authorization_request.state
    when 'draft'
      %w[fr-badge--grey fr-badge--no-icon]
    when 'changes_requested'
      %w[fr-badge--warning]
    when 'submitted'
      %w[fr-badge--info]
    when 'validated'
      %w[fr-badge--success]
    when 'refused', 'revoked'
      %w[fr-badge--error]
    when 'archived'
      %w[fr-badge--secondary]
    end
  end

  def authorization_request_reopening_badge
    content_tag(
      :span,
      t('authorization_request.reopening'),
      class: 'fr-badge fr-badge--purple-glycine',
    )
  end

  def authorization_request_status_badge_translation(authorization_request, scope)
    case scope
    when :instruction, 'instruction'
      "instruction.authorization_requests.index.status.#{authorization_request.state}"
    else
      "authorization_request.status.#{authorization_request.state}"
    end
  end
end
