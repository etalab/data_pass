class HistoriqueEventsComponent < ViewComponent::Base
  attr_reader :authorization_request_event

  def initialize(authorization_request_event:)
    @authorization_request_event = authorization_request_event
  end

  def icon_class
    [
      "fr-icon-#{t(".#{authorization_request_event.name}.icon", default: 'error-warning-line')}",
      "fr-text-#{t(".#{authorization_request_event.name}.color", default: 'info')}",
    ]
  end

  def message_summary
    content = message_content.to_s

    summary = if content.include?(':')
      content.split(':', 2).first
    elsif content.include?("\n")
      content.split("\n", 2).first
    else
      plain_content = strip_tags(content)
      words = plain_content.split
      words.size <= 10 ? plain_content : "#{words.first(10).join(' ')}..."
    end

    strip_tags(summary)
  end

  def message_content
    return @message_content if defined?(@message_content)

    I18n.t(
      "instruction.authorization_request_events.authorization_request_event.#{authorization_request_event.name}.text",
      ** {
           user_full_name: authorization_request_event.user_full_name,
           text: authorization_request_event.text,
           copied_from_authorization_request_id: authorization_request_event.copied_from_authorization_request_id,
         }.compact
    ).html_safe
  end

  def text_present?
    authorization_request_event.text.present?
  end

  # Delegate helper methods to the view context
  # We use helpers only in the template, not in the component methods
  delegate :dom_id, :strip_tags, :t, :time_tag, :link_to,
           :authorization_request_authorization_path,
           :content_tag,
           to: :helpers
end
