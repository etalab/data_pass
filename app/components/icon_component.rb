class IconComponent < ViewComponent::Base
  ICONS = {
            'approve' => { icon: 'checkbox-line', color: 'success' },
            'request_changes' => { icon: 'pencil-line', color: 'warning' },
            'refuse' => { icon: 'close-circle-line', color: 'error' },
            'revoke' => { icon: 'close-circle-line', color: 'error' },
          }.freeze

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
    event = available_icons[@name] || (raise 'Invalid icon')

    %W[fr-icon-#{event[:icon]} fr-text-#{event[:color]}].join(' ')
  end
end
