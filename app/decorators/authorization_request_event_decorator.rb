class AuthorizationRequestEventDecorator < ApplicationDecorator
  delegate_all

  def user_full_name
    user&.full_name
  end

  def name
    case object.name
    when 'submit'
      changelog_presenter.event_name
    when 'cancel_reopening'
      name_for_cancel_reopening
    else
      object.name
    end
  end

  def text
    case name
    when 'refuse', 'request_changes', 'revoke', 'cancel_reopening_from_instructor', 'bulk_update'
      format_text(entity.reason)
    when 'applicant_message', 'instructor_message'
      format_text(entity.body)
    when 'initial_submit_with_changes_on_prefilled_data', 'submit_with_changes'
      humanized_changelog
    when 'admin_update'
      humanized_changelog(from_admin: true)
    when 'transfer'
      format_transfer_text
    end
  end

  def copied_from_authorization_request_id
    return unless name == 'copy'

    entity.copied_from_request.id
  end

  def to_key
    nil
  end

  private

  def format_text(content)
    h.simple_format(content)
  end

  def format_transfer_text
    if entity.from_type == 'User'
      "#{entity.to.full_name} (#{entity.to.email})"
    else
      "l'organisation #{entity.to.raison_sociale} (numéro SIRET : #{entity.to.siret})"
    end
  end

  def humanized_changelog(from_admin: false)
    h.content_tag(:ul) do
      changelog_presenter(from_admin:).consolidated_changelog_entries.map { |entry|
        h.content_tag(:li, entry)
      }.join.html_safe
    end
  end

  def changelog_presenter(from_admin: false)
    @changelog_presenter ||= AuthorizationRequestChangelogPresenter.new(entity, from_admin:)
  end

  def name_for_cancel_reopening
    if object.entity.from_instructor?
      'cancel_reopening_from_instructor'
    else
      'cancel_reopening_from_applicant'
    end
  end
end
