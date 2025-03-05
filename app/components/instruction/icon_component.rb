class Instruction::IconComponent < ViewComponent::Base
  ICONS = {
    'approve' => { icon: 'checkbox-line', color: 'success' },
    'request_changes' => { icon: 'pencil-line', color: 'warning' },
    'refuse' => { icon: 'close-circle-line', color: 'error' },
    'revoke' => { icon: 'close-circle-line', color: 'error' },
  }.freeze

  def initialize(event_name:, **options)
    @event_name = event_name
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

  def icon_class
    event = ICONS[@event_name] || { icon: 'error-warning-line', color: 'info' }

    %W[fr-icon-#{event[:icon]} fr-text-#{event[:color]}].join(' ')
  end
end
