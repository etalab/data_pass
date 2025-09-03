module SkipLinks
  TAB_PREFIX = 'tab-'.freeze

  def skip_link(text, anchor)
    anchor_str = anchor.to_s
    content_tag(:li) do
      if anchor_str.start_with?(TAB_PREFIX)
        link_to(text, "##{anchor_str}", class: 'fr-link', data: { anchor: anchor_str })
      else
        link_to(text, "##{anchor_str}", class: 'fr-link')
      end
    end
  end

  def default_skip_links
    [
      skip_link(content_skip_link_text, 'content'),
      skip_link('Menu', 'header'),
      skip_link('Pied de page', 'footer')
    ].join.html_safe
  end

  def skip_links_content
    return content_for(:skip_links) if content_for?(:skip_links)

    validate_skip_links_in_test! if Rails.env.test?

    default_skip_links
  end

  private

  def content_skip_link_text
    content_for?(:content_skip_link_text) ? content_for(:content_skip_link_text) : 'Aller au contenu'
  end

  def validate_skip_links_in_test!
    SkipLinksImplementedChecker.new(
      controller_name: controller_path,
      action_name: action_name,
      has_skip_links: content_for?(:skip_links)
    ).perform!
  end
end
