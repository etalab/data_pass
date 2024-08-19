class AuthorizationRequestEventDecorator < ApplicationDecorator
  delegate_all

  def user_full_name
    return unless user

    user.full_name
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

  # rubocop:disable Metrics/AbcSize
  def text
    case name
    when 'refuse', 'request_changes', 'revoke', 'cancel_reopening_from_instructor'
      h.simple_format(entity.reason)
    when 'applicant_message', 'instructor_message'
      h.simple_format(entity.body)
    when 'initial_submit_with_changes_on_prefilled_data', 'submit_with_changes', 'admin_update'
      humanized_changelog
    when 'transfer'
      if entity.from_type == 'User'
        "#{entity.to.full_name} (#{entity.to.email})"
      else
        "l'organisation #{entity.to.raison_sociale} (numéro SIRET : #{entity.to.siret})"
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def copied_from_authorization_request_id
    return unless name == 'copy'

    entity.copied_from_request.id
  end

  private

  def humanized_changelog
    h.content_tag(:ul) do
      changelog_presenter.consolidated_changelog_entries.map { |entry|
        h.content_tag(:li, entry)
      }.join.html_safe
    end
  end

  def changelog_presenter
    @changelog_presenter ||= AuthorizationRequestChangelogPresenter.new(entity)
  end

  def name_for_cancel_reopening
    if object.entity.from_instructor?
      'cancel_reopening_from_instructor'
    else
      'cancel_reopening_from_applicant'
    end
  end
end
