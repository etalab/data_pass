class HistoricalAuthorizationRequestEventComponent < ApplicationComponent
  with_collection_parameter :authorization_request_event

  delegate :user_full_name, :entity, to: :authorization_request_event
  delegate :authorization_request_authorization_path, to: :helpers

  attr_reader :authorization_request_event
  alias event authorization_request_event

  def initialize(authorization_request_event:)
    @authorization_request_event = authorization_request_event
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
    @message_details_text ||= case name
                              when 'request_changes', 'revoke', 'refuse'
                                simple_format(entity.reason)
                              when 'applicant_message', 'instructor_message'
                                simple_format(entity.body)
                              when 'initial_submit_with_changes_on_prefilled_data', 'submit_with_changes'
                                humanized_changelog
                              when 'admin_update'
                                humanized_changelog(from_admin: true)
                              end
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
      transfer_text:
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

    if entity.present?
      "la demande #{entity.copied_from_request.id}"
    else
      'une demande qui n\'existe plus (celle-ci a été supprimée ou fusionnée avec cette demande)'
    end
  end

  def external_link?
    event.name == 'approve'
  end

  def formatted_created_at_date
    event.created_at.strftime('%d/%m/%Y')
  end

  private

  def humanized_changelog(from_admin: false)
    helpers.content_tag(:ul) do
      changelog_presenter(from_admin:).consolidated_changelog_entries.map { |entry|
        helpers.content_tag(:li, entry)
      }.join.html_safe
    end
  end

  def changelog_presenter(from_admin: false)
    @changelog_presenter ||= AuthorizationRequestChangelogPresenter.new(entity, from_admin:)
  end

  def name_for_cancel_reopening
    if event.entity.from_instructor?
      'cancel_reopening_from_instructor'
    else
      'cancel_reopening_from_applicant'
    end
  end
end
