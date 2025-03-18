class LinkComponent < ApplicationComponent
  def initialize(text:, path:, **options)
    @text = text
    @path = path
    @options = merge_options(options)
  end

  def call
    link_to(
      @text,
      @path,
      **@options
    )
  end

  private

  def default_options
    {
      class: 'fr-link',
      rel: 'noopener'
    }
  end

  def merge_options(custom_options)
    merged_options = default_options.merge(custom_options.except(:class))
    merged_options[:class] = [default_options[:class], custom_options[:class]].flatten
    merged_options
  end
end
