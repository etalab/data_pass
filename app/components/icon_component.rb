class IconComponent < ViewComponent::Base
  def initialize(name:, **options)
    @name = name
    @options = options
  end

  def call
    content_tag(
      :i,
      nil,
      class: icon_class,
      aria: { hidden: true },
      **@options
    )
  end

  private

  def available_icons
    fail NotImplementedError
  end

  def icon_class
    name = available_icons[@name] || (raise 'Invalid icon')

    %W[fr-icon-#{name[:icon]} fr-text-#{name[:color]}].join(' ')
  end
end
