module SkipLinks
  def skip_link(text, anchor)
    content_tag(:li) do
      if anchor.start_with?('tab-')
        link_to(text, "##{anchor}", class: 'fr-link', onclick: "document.getElementById('#{anchor}')?.click(); return false;")
      else
        link_to(text, "##{anchor}", class: 'fr-link')
      end
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
    elsif Rails.env.test? && !whitelisted_for_default_skip_links? && renders_html_view?
      current_route = "#{controller_name}##{action_name}"
      current_path = begin
        request.path
      rescue StandardError
        'unknown'
      end
      raise "No skip links defined for this page (#{current_route} - #{current_path}). Use content_for(:skip_links) to define skip links or define them in a view-specific helper."
    else
      default_skip_links
    end
  end

  def renders_html_view?
    request.format.html? && !request.xhr? && response.content_type&.include?('text/html')
  rescue StandardError
    respond_to?(:content_for?) && respond_to?(:render)
  end

  private

  def whitelisted_for_default_skip_links?
    whitelist = %w[
      authorizations#show
      authorization_requests#index
      authorization_requests#show
      authorization_requests#new
      authorization_request_forms#new
      authorization_request_forms#start
      authorization_request_forms#summary
      authorization_request_forms/build#show
      authorization_definitions#index
      pages#home
      pages#accessibilite
      stats#index
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
    ]

    whitelist.include?("#{controller_name}##{action_name}")
  end
end
