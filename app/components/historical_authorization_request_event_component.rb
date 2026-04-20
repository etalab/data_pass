class HistoricalAuthorizationRequestEventComponent < ApplicationComponent
  with_collection_parameter :authorization_request_event

  REASON_EVENTS = %w[request_changes revoke refuse bulk_update cancel_reopening_from_instructor].freeze
  MESSAGE_EVENTS = %w[applicant_message instructor_message].freeze
  CHANGELOG_EVENTS = %w[initial_submit_with_changes_on_prefilled_data submit_with_changes legacy_submit_with_changes].freeze

  delegate :user_full_name, :entity, to: :authorization_request_event

  attr_reader :authorization_request_event
  alias event authorization_request_event

  def initialize(authorization_request_event:, show_private_reason: false)
    @authorization_request_event = authorization_request_event
    @show_private_reason = show_private_reason
  end

  def before_render
    message_details_text
  end

  def name
    case authorization_request_event.name
    when 'submit'
      changelog_presenter.event_name
    when 'cancel_reopening'
      name_for_cancel_reopening
    else
      authorization_request_event.name
    end
  end

  def message_details_text
    @message_details_text ||= compute_message_details_text
  end

  def message_expandable?
    message_details_text.present?
  end

  def transfer_text
    return unless name == 'transfer'

    if entity.from_type == 'User'
      "#{entity.to.full_name} (#{entity.to.email})"
    else
      "l'organisation #{entity.to.name} (numéro SIRET : #{entity.to.siret})"
    end
  end

  def message_content
    @message_content ||= "#{message_summary} #{message_details}".html_safe
  end

  def message_summary
    I18n.t(
      "instruction.authorization_request_events.authorization_request_event.#{name}.message_summary",
      user_full_name: event.user_full_name,
      copied_from_authorization_request_id:,
      transfer_text:,
      definition_name: event.entity.try(:definition)&.name
    ).html_safe
  end

  def message_details
    I18n.t(
      "instruction.authorization_request_events.authorization_request_event.#{name}.message_details",
      message_details_text:,
      copied_from_authorization_request_id:
    ).html_safe
  end

  def copied_from_authorization_request_id
    return unless name == 'copy'

    if entity.present? && entity.copied_from_request_id.present?
      "la demande #{entity.copied_from_request_id}"
    else
      'une demande qui n\'existe plus (celle-ci a été supprimée ou fusionnée avec cette demande)'
    end
  end

  def external_link?
    %w[approve auto_generate].include?(event.name)
  end

  def formatted_created_at_date
    event.created_at.strftime('%d/%m/%Y')
  end

  private

  def compute_message_details_text
    return formatted_reason if REASON_EVENTS.include?(name)
    return formatted_body if MESSAGE_EVENTS.include?(name)
    return formatted_approval_message if approval_with_message?
    return humanized_changelog if CHANGELOG_EVENTS.include?(name)

    return humanized_changelog(from_admin: true) if name == 'admin_update'

    formatted_admin_change if name == 'admin_change'
  end

  def formatted_reason
    simple_format(entity.reason)
  end

  def formatted_body
    simple_format(entity.body)
  end

  def formatted_approval_message
    simple_format(entity.message)
  end

  def approval_with_message?
    name == 'approve' && entity.message.present?
  end

  def humanized_changelog(from_admin: false)
    render_diff_list(changelog_presenter(from_admin:).consolidated_changelog_entries)
  end

  def changelog_presenter(from_admin: false)
    @changelog_presenter ||= AuthorizationRequestChangelogPresenter.new(entity, from_admin:)
  end

  def formatted_admin_change
    diff_entries = DiffPresenter.new(entity.diff, entity.authorization_request).entries
    parts = []
    parts << formatted_private_reason if show_private_reason?
    parts << simple_format(entity.public_reason)
    parts << render_diff_list(diff_entries)
    safe_join(parts)
  end

  def show_private_reason?
    @show_private_reason && entity.private_reason.present?
  end

  def formatted_private_reason
    helpers.content_tag(:div, class: 'fr-alert fr-alert--info fr-alert--sm fr-mb-2w fr-icon-eye-off-line') do
      helpers.content_tag(:p, entity.private_reason)
    end
  end

  def render_diff_list(entries)
    helpers.render(DiffListComponent.new(entries:))
  end

  def name_for_cancel_reopening
    if event.entity.from_instructor?
      'cancel_reopening_from_instructor'
    else
      'cancel_reopening_from_applicant'
    end
  end

  def event_kind
    case event.name
    when 'refuse', 'revoke', 'request_changes', 'applicant_message', 'instructor_message', 'bulk_update', 'approve', 'cancel_reopening'
      :message
    when 'admin_change'
      :details
    when 'submit', 'admin_update'
      :changelog
    end
  end
end
