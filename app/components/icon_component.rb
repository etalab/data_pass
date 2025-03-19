class IconComponent < ApplicationComponent
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
    icon = available_icons[@name]
    raise 'Invalid icon' unless icon

    %W[fr-icon-#{icon[:icon]} fr-text-#{icon[:color]}].join(' ')
  end
end
