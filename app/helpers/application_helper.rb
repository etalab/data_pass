module ApplicationHelper
  include DSFR::Stepper
  include DSFR::Accordion
  include DSFR::Modal
  include DSFR::Pictogram

  def provider_logo_image_tag(authorization_definition, options = {})
    options = options.merge(alt: "Logo du fournisseur de données \" #{@authorization_definition.provider.name}\"")
    image_tag("data_providers/#{authorization_definition.provider.logo}", options)
  end

  def authorization_request_status_badge(authorization_request, no_icon: false)
    content_tag(
      :span,
      t("authorization_request.status.#{authorization_request.state}"),
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
      %w[fr-badge--purple-glycine fr-badge--no-icon]
    when 'changes_requested'
      %w[fr-badge--warning]
    when 'submitted'
      %w[fr-badge--info]
    when 'validated'
      %w[fr-badge--success]
    when 'refused', 'revoked'
      %w[fr-badge--error fr-badge--no-icon]
    when 'archived'
      %w[fr-badge--secondary]
    end
  end

  def authorization_request_reopening_badge
    content_tag(
      :span,
      t('authorization_request.reopening'),
      class: 'fr-badge fr-badge--no-icon fr-badge--purple-glycine',
    )
  end
end
