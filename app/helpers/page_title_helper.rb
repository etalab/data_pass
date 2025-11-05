module PageTitleHelper
  def page_title(title = nil, separator: ' - ', site_name: 'DataPass')
    return site_name if title.blank?

    safe_join([title, site_name], separator)
  end

  def provide_title(title)
    content_for(:page_title, title)
  end

  def display_page_title
    page_title(content_for(:page_title))
  end
end
