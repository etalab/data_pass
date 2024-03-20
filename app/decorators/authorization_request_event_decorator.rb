class AuthorizationRequestEventDecorator < ApplicationDecorator
  delegate_all

  def user_full_name
    return unless user

    user.full_name
  end

  def name
    case object.name
    when 'submit'
      if initial_submit_with_changed_prefilled?
        'initial_submit_with_changed_prefilled'
      elsif initial_submit?
        'initial_submit'
      else
        'submit'
      end
    else
      object.name
    end
  end

  def text
    case name
    when 'refuse', 'request_changes'
      entity.reason
    when 'submit'
      humanized_changelog
    when 'initial_submit_with_changed_prefilled'
      humanized_changelog_without_blank_values
    when 'applicant_message', 'instructor_message'
      entity.body
    end
  end
  alias comment text # see WebhookEventSerializer

  private

  def humanized_changelog
    changelog_builder(changelog_diffs)
  end

  def humanized_changelog_without_blank_values
    changelog_builder(changelog_diffs_without_blank_values)
  end

  def changelog_builder(diffs)
    h.content_tag(:ul) do
      diffs.map { |attribute, values|
        h.content_tag(:li, build_attribute_change(attribute, values))
      }.join.html_safe
    end
  end

  def changelog_diffs
    object.entity.diff
  end

  def changelog_diffs_without_blank_values
    changelog_diffs.reject { |_h, v| v[0].blank? }
  end

  def build_attribute_change(attribute, values)
    t(
      'authorization_request_event.changelog_entry',
      attribute: object.authorization_request.class.human_attribute_name(attribute),
      old_value: values.first,
      new_value: values.last,
    )
  end

  def initial_submit?
    object.authorization_request.changelogs.one?
  end

  def initial_submit_with_changed_prefilled?
    initial_submit? &&
      object.authorization_request.form.prefilled? &&
      prefilled_changed?
  end

  def prefilled_changed?
    object.authorization_request.form.data.any? do |key, value|
      object.authorization_request.data[key] != value
    end
  end
end
