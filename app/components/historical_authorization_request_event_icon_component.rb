class HistoricalAuthorizationRequestEventIconComponent < IconComponent
  private

  def available_icons
    {
      'approve' => { icon: 'checkbox-line', color: 'success' },
      'request_changes' => { icon: 'pencil-line', color: 'warning' },
      'refuse' => { icon: 'close-circle-line', color: 'error' },
      'revoke' => { icon: 'close-circle-line', color: 'error' },
    }.freeze
  end

  def icon_class
    event = available_icons[@name] || { icon: 'error-warning-line', color: 'info' }
    %W[fr-icon-#{event[:icon]} fr-text-#{event[:color]}].join(' ')
  end
end
