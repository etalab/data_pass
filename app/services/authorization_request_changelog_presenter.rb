class AuthorizationRequestChangelogPresenter
  attr_reader :changelog

  delegate :t, to: I18n

  def initialize(changelog, from_admin: true)
    @changelog = changelog
    @from_admin = from_admin
  end

  def event_name
    return legacy_changelog_name if changelog.legacy?
    return legacy_changelog_name if previous_legacy_without_snapshot?
    return initial_submit_event_name if first_changelog?

    no_change? ? 'submit_without_changes' : 'submit_with_changes'
  end

  def consolidated_changelog_entries
    return diff_presenter.entries if from_admin?

    case event_name
    when 'initial_submit_with_changes_on_prefilled_data'
      diff_presenter_for_prefilled_changes.entries
    when 'submit_with_changes', 'legacy_submit_with_changes'
      diff_presenter.entries
    else
      []
    end
  end

  private

  def diff_presenter
    @diff_presenter ||= DiffPresenter.new(changelog.diff, authorization_request)
  end

  def diff_presenter_for_prefilled_changes
    changed_prefilled_diff = changelog.diff.select do |_, values|
      values[0].present? && values[1] != values[0]
    end

    DiffPresenter.new(changed_prefilled_diff, authorization_request)
  end

  def initial_submit_event_name
    if !prefilled_data?
      'initial_submit_without_prefilled_data'
    elsif prefilled_changed?
      'initial_submit_with_changes_on_prefilled_data'
    else
      'initial_submit_without_changes_on_prefilled_data'
    end
  end

  def legacy_changelog_name
    if no_change?
      'legacy_submit_without_changes'
    else
      'legacy_submit_with_changes'
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

  def previous_legacy_without_snapshot?
    authorization_request.changelogs.where(legacy: true).any? &&
      authorization_request.latest_authorization.nil?
  end

  def authorization_request
    changelog.authorization_request
  end

  def from_admin?
    @from_admin
  end
end
