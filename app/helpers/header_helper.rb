module HeaderHelper
  def header_title
    return registered_subdomain.title if registered_subdomain? && registered_subdomain.title.present?

    t('layouts.header.title')
  end

  def header_tagline
    return registered_subdomain.tagline if registered_subdomain? && registered_subdomain.tagline.present?

    t('layouts.header.tagline')
  end
end
