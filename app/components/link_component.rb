class LinkComponent < ApplicationComponent
  def initialize(text: nil, path: nil, i18n_key: nil, **options)
    @text = text
    @path = path
    @i18n_key = i18n_key
    @options = merge_options(options)
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

  def merge_options(custom_options)
    merged_options = default_options.merge(custom_options.except(:class))
    merged_options[:class] = [default_options[:class], custom_options[:class]].compact.join(' ')
    merged_options
  end
end
