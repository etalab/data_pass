class AuthorizationRequestChangelogPresenter
  attr_reader :changelog, :h

  delegate :t, to: I18n

  def initialize(changelog, h)
    @changelog = changelog
    @h = h
  end

  def event_name
    if changelog.diff.blank?
      'submit_without_changes'
    elsif initial_submit_with_changed_prefilled? && changelog_diff_without_unchanged_prefilled_values_and_new_values.blank?
      'submit_with_unchanged_prefilled_values'
    elsif initial_submit_with_changed_prefilled?
      'initial_submit_with_changed_prefilled'
    elsif initial_submit?
      'initial_submit'
    else
      'submit'
    end
  end

  def humanized_changelog
    if event_name == 'initial_submit_with_changed_prefilled'
      changelog_builder(changelog_diff_without_unchanged_prefilled_values_and_new_values)
    else
      changelog_builder(changelog.diff)
    end
  end

  private

  def changelog_builder(diffs)
    h.content_tag(:ul) do
      diffs.map { |attribute, values|
        if attribute == 'scopes'
          build_scopes_change(values)
        elsif attribute == 'applicant_id'
          h.content_tag(:li, build_applicant_change(attribute, values))
        else
          h.content_tag(:li, build_attribute_change(attribute, values))
        end
      }.flatten.join.html_safe
    end
  end

  # rubocop:disable Metrics/AbcSize
  def changelog_diff_without_unchanged_prefilled_values_and_new_values
    changelog.diff.reject do |h, v|
      if authorization_request.form.data[h.to_sym].blank?
        v[0].blank?
      else
        authorization_request.public_send(h) == authorization_request.form.data[h.to_sym]
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def build_scopes_change(values)
    initial_values = values[0] || []
    new_scopes = values[1] - initial_values
    removed_scopes = initial_values - values[1]

    [
      new_scopes.map do |scope|
        h.content_tag(:li, t('authorization_request_event.changelog_entry_new_scope', value: humanized_scope(scope)).html_safe)
      end,
      removed_scopes.map do |scope|
        h.content_tag(:li, t('authorization_request_event.changelog_entry_removed_scope', value: humanized_scope(scope)).html_safe)
      end
    ]
  end
  # rubocop:enable Metrics/AbcSize

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
      new_value: h.sanitize(values.last.to_s),
    ).html_safe
  end

  def build_attribute_change_with_values(attribute, values)
    t(
      'authorization_request_event.changelog_entry',
      attribute: authorization_request.class.human_attribute_name(attribute),
      old_value: h.sanitize(values.first.to_s),
      new_value: h.sanitize(values.last.to_s),
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
      t('authorization_request_event.changelog_entry_applicant_with_missing_data')
    end
  end

  def initial_submit?
    authorization_request.events.where(name: 'submit').order(created_at: :asc).first == changelog.event
  end

  def initial_submit_with_changed_prefilled?
    initial_submit? &&
      (
        from_form_with_prefilled_data_with_changes? ||
          authorization_request_is_a_copy?
      )
  end

  def from_form_with_prefilled_data_with_changes?
    authorization_request.form.prefilled? &&
      prefilled_changed?
  end

  def prefilled_changed?
    authorization_request.form.data.any? do |key, value|
      authorization_request.public_send(key) != value
    end
  end

  def authorization_request
    changelog.authorization_request
  end

  def authorization_request_is_a_copy?
    authorization_request.events.exists?(name: 'copy')
  end
end
