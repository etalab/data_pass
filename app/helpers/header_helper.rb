module HeaderHelper
  def header_title
    return registered_subdomain.title if registered_subdomain? && registered_subdomain.title.present?

    t('layouts.header.title')
  end

  def header_tagline
    return registered_subdomain.tagline if registered_subdomain? && registered_subdomain.tagline.present?
    return t('layouts.header.public_tagline') if public_header?

    t('layouts.header.tagline')
  end

  def public_menu_links
    [
      { label: t('layouts.header.menu.public.home'), path: root_path },
      { label: t('layouts.header.menu.public.european_wallet'), path: european_wallet_page_path }
    ]
  end
end
