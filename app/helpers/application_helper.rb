module ApplicationHelper
  include DSFR::Stepper
  include DSFR::Accordion
  include DSFR::Modal
  include DSFR::Pictogram

  def provider_logo_path(authorization_definition)
    "data_providers/#{authorization_definition.provider.logo}"
  end

  def authorization_request_status_badge(authorization_request, no_icon: false)
    content_tag(
      :p,
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
    end
  end
end
