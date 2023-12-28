module ApplicationHelper
  def provider_logo_path(authorization_definition)
    "data_providers/#{authorization_definition.provider.logo}"
  end

  def authorization_request_status_badge(authorization_request)
    content_tag(:p, t("authorization_request.status.#{authorization_request.state}"), class: "fr-badge #{authorization_request_status_badge_class(authorization_request)}")
  end

  def authorization_request_status_badge_class(authorization_request)
    case authorization_request.state
    when 'draft'
      'fr-badge--purple-glycine fr-badge--no-icon'
    when 'changes_requested'
      'fr-badge--warning'
    when 'submitted'
      'fr-badge--info'
    when 'validated'
      'fr-badge--success'
    when 'refused', 'revoked'
      'fr-badge--error fr-badge--no-icon'
    end
  end
end
