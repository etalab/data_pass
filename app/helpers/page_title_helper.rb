module PageTitleHelper
  SITE_NAME = 'DataPass'.freeze

  def set_title!(title = nil, separator: ' - ', site_name: SITE_NAME)
    full_title = format_title(title, separator: separator, site_name: site_name)
    content_for(:page_title, full_title, flush: true)
  end

  def format_title(title = nil, separator: ' - ', site_name: SITE_NAME)
    safe_join([title, site_name].compact_blank, separator)
  end

  def page_title
    content_for(:page_title) || format_title
  end
end
