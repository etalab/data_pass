class ExternalLinkComponent < ViewComponent::Base
  def initialize(text: nil, path: nil, i18n_key: nil, **options)
    @text = text
    @path = path
    @i18n_key = i18n_key
    @options = default_options.merge(options)
  end

  def call
    return if @path.blank?

    link_to(
      link_text,
      @path,
      **@options
    )
  end

  private

  def link_text
    @text || (@i18n_key.present? ? t(@i18n_key) : '')
  end

  def default_options
    {
      target: '_blank',
      class: 'fr-link',
      rel: 'noopener'
    }
  end
end
