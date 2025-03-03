class Instruction::HistoricalEventsComponent < ViewComponent::Base
  attr_reader :authorization_request_event

  def initialize(authorization_request_event:)
    @authorization_request_event = authorization_request_event
  end

  def message_summary
    content = stripped_message_content

    summary = if content.include?(':')
      content.split(':', 2).first
    elsif content.include?("\n")
      content.split("\n", 2).first
    else
      words = content.split
      words.size <= 10 ? content : "#{words.first(10).join(' ')}..."
    end

    add_colon_if_needed(summary, content)
  end

  def message_content
    return @message_content if defined?(@message_content)

    @message_content =
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

  delegate :dom_id, :strip_tags, :t, :time_tag, :link_to,
           :authorization_request_authorization_path,
           :content_tag,
           to: :helpers

  private

  def stripped_message_content
    strip_tags(message_content.to_s)
  end

  def add_colon_if_needed(summary, content)
    summary += ':' if summary != content && !summary.strip.end_with?(':')
    summary
  end
end
