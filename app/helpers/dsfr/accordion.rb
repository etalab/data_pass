module DSFR::Accordion
  def dsfr_accordion(title, content, options = {})
    options[:id] ||= SecureRandom.uuid

    template.content_tag(:section, class: (options[:class] || []) << 'fr-accordion') do
      [
        dsfr_accordion_title(title, options),
        dsfr_accordion_content(content, options)
      ].join.html_safe
    end
  end

  private

  def dsfr_accordion_title(title, options)
    template.content_tag(:h3, class: 'fr-accordion__title') do
      template.button_tag(
        title,
        class: 'fr-accordion__btn',
        aria: {
          expanded: 'false',
          controls: options[:id],
        },
        type: 'button'
      )
    end
  end

  def dsfr_accordion_content(content, options)
    template.content_tag(:div, class: 'fr-collapse', id: options[:id]) do
      content.html_safe
    end
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def template
    @template || self
  end
  # rubocop:enable Rails/HelperInstanceVariable
end
