class AuthorizationRequestChangelogPresenter
  include ActionView::Helpers::SanitizeHelper

  attr_reader :changelog

  delegate :t, to: I18n

  def initialize(changelog, from_admin: true)
    @changelog = changelog
    @from_admin = from_admin
  end

  def event_name
    return legacy_changelog_name if any_changelog_legacy?

    if first_changelog?
      if !prefilled_data?
        'initial_submit_without_prefilled_data'
      elsif prefilled_changed?
        'initial_submit_with_changes_on_prefilled_data'
      else
        'initial_submit_without_changes_on_prefilled_data'
      end
    elsif no_change?
      'submit_without_changes'
    else
      'submit_with_changes'
    end
  end

  def consolidated_changelog_entries
    return changelog_builder(changelog_diff) if from_admin?

    case event_name
    when 'initial_submit_with_changes_on_prefilled_data'
      changelog_builder(changelog_diff_without_unchanged_prefilled_values_and_new_values)
    when 'submit_with_changes', 'legacy_submit_with_changes'
      changelog_builder(changelog_diff)
    else
      []
    end
  end

  private

  def legacy_changelog_name
    if no_change?
      'legacy_submit_without_changes'
    else
      'legacy_submit_with_changes'
    end
  end

  def changelog_builder(diffs)
    diffs.map { |attribute, values|
      values = sanitize_values(attribute, values)

      if attribute == 'scopes'
        build_scopes_change(values)
      elsif attribute == 'applicant_id'
        build_applicant_change(attribute, values)
      else
        build_attribute_change(attribute, values)
      end
    }.flatten
  end

  def sanitize_values(attribute, values)
    case attribute
    when 'scopes'
      values.map do |scopes|
        sanitize_values('scope', scopes || [])
      end
    else
      values.map do |value|
        sanitize(value)
      rescue NoMethodError
        value
      end
    end
  end

  def changelog_diff_without_unchanged_prefilled_values_and_new_values
    changelog_diff.select do |_, values|
      values[0].present? && values[1] != values[0]
    end
  end

  def changelog_diff
    changelog.diff.reject { |_, values| values[0] == values[1] }
  end

  def build_scopes_change(values)
    initial_values = values[0] || []
    new_scopes = values[1] - initial_values
    removed_scopes = initial_values - values[1]

    [
      new_scopes.map do |scope|
        t('authorization_request_event.changelog_entry_new_scope', value: humanized_scope(scope)).html_safe
      end,
      removed_scopes.map do |scope|
        t('authorization_request_event.changelog_entry_removed_scope', value: humanized_scope(scope)).html_safe
      end
    ]
  end

  def humanized_scope(scope_value)
    scope = authorization_request.definition.scopes.find { |s| s.value == scope_value }

    if scope
      [scope.name, "(#{scope_value})"].join(' ')
    else
      scope_value
    end
  end

  def build_attribute_change(attribute, values)
    if values[0].blank?
      build_attribute_initial_change(attribute, values)
    else
      build_attribute_change_with_values(attribute, values)
    end
  end

  def build_attribute_initial_change(attribute, values)
    t(
      'authorization_request_event.changelog_entry_with_null_old_value',
      attribute: authorization_request.class.human_attribute_name(attribute),
      new_value: values.last.to_s,
    ).html_safe
  end

  def build_attribute_change_with_values(attribute, values)
    t(
      'authorization_request_event.changelog_entry',
      attribute: authorization_request.class.human_attribute_name(attribute),
      old_value: values.first.to_s,
      new_value: values.last.to_s,
    ).html_safe
  end

  def build_applicant_change(attribute, values)
    from_user, to_user = values.map { |id| User.find_by(id:) }

    if from_user && to_user
      t(
        'authorization_request_event.changelog_entry_applicant',
        attribute: authorization_request.class.human_attribute_name(attribute),
        old_value: from_user.email,
        new_value: to_user.email,
      ).html_safe
    else
      t('authorization_request_event.changelog_entry_applicant_with_missing_data').html_safe
    end
  end

  def first_changelog?
    changelog.initial?
  end

  def prefilled_data?
    changelog.diff.any? { |_, values| values[0].present? }
  end

  def prefilled_changed?
    changelog.diff.any? { |_, values| values[0].present? && values[0] != values[1] }
  end

  def no_change?
    changelog.diff.empty?
  end

  def any_changelog_legacy?
    changelog.legacy? ||
      authorization_request.changelogs.where(legacy: true).any?
  end

  def authorization_request
    changelog.authorization_request
  end

  def from_admin?
    @from_admin
  end
end
