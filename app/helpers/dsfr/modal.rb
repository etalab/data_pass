module Dsfr::Modal
  def dsfr_main_modal_button(title, url, opts = {})
    opts[:turbo_frame] = 'main-modal-content'
    opts[:url] = url

    dsfr_modal_button(title, 'main-modal', opts)
  end

  def dsfr_modal_button(title, modal_id, opts = {})
    url = opts.delete(:url)
    turbo_frame = opts.delete(:turbo_frame)
    css_classes = opts.delete(:class)

    content_tag(
      url ? :a : :button,
      title,
      opts.merge(
        class: css_classes,
        type: 'button',
        href: url,
        id: [modal_id, 'button'].join('_'),
        aria: {
          controls: modal_id,
        },
        data: {
          'fr-opened': false,
          'turbo-frame': turbo_frame,
        }
      )
    )
  end
end
