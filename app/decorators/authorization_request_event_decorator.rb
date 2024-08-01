class AuthorizationRequestEventDecorator < ApplicationDecorator
  delegate_all

  def user_full_name
    return unless user

    user.full_name
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def name
    case object.name
    when 'submit'
      if object.entity.diff.blank?
        'submit_without_changes'
      elsif initial_submit_with_changed_prefilled? && changelog_diffs_without_unchanged_prefilled_values_and_new_values.blank?
        'submit_with_unchanged_prefilled_values'
      elsif initial_submit_with_changed_prefilled?
        'initial_submit_with_changed_prefilled'
      elsif initial_submit?
        'initial_submit'
      else
        'submit'
      end
    when 'cancel_reopening'
      if object.entity.from_instructor?
        'cancel_reopening_from_instructor'
      else
        'cancel_reopening_from_applicant'
      end
    else
      object.name
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def text
    case name
    when 'refuse', 'request_changes', 'revoke', 'cancel_reopening_from_instructor'
      h.simple_format(entity.reason)
    when 'submit', 'admin_update'
      humanized_changelog
    when 'initial_submit_with_changed_prefilled'
      humanized_changelog_without_unchanged_prefilled_values_and_new_values
    when 'applicant_message', 'instructor_message'
      h.simple_format(entity.body)
    when 'transfer'
      if entity.from_type == 'User'
        "#{entity.to.full_name} (#{entity.to.email})"
      else
        "l'organisation #{entity.to.raison_sociale} (numéro SIRET : #{entity.to.siret})"
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def copied_from_authorization_request_id
    return unless name == 'copy'

    entity.copied_from_request.id
  end

  private

  def humanized_changelog
    changelog_builder(changelog_diffs)
  end

  def humanized_changelog_without_unchanged_prefilled_values_and_new_values
    changelog_builder(changelog_diffs_without_unchanged_prefilled_values_and_new_values)
  end

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

  def changelog_diffs
    object.entity.diff
  end

  # rubocop:disable Metrics/AbcSize
  def changelog_diffs_without_unchanged_prefilled_values_and_new_values
    changelog_diffs.reject do |h, v|
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
    new_scopes = values[1] - values[0]
    removed_scopes = values[0] - values[1]

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
      attribute: object.authorization_request.class.human_attribute_name(attribute),
      new_value: h.sanitize(values.last.to_s),
    ).html_safe
  end

  def build_attribute_change_with_values(attribute, values)
    t(
      'authorization_request_event.changelog_entry',
      attribute: object.authorization_request.class.human_attribute_name(attribute),
      old_value: h.sanitize(values.first.to_s),
      new_value: h.sanitize(values.last.to_s),
    ).html_safe
  end

  def build_applicant_change(attribute, values)
    from_user, to_user = values.map { |id| User.find_by(id:) }

    if from_user && to_user
      t(
        'authorization_request_event.changelog_entry_applicant',
        attribute: object.authorization_request.class.human_attribute_name(attribute),
        old_value: from_user.email,
        new_value: to_user.email,
      ).html_safe
    else
      t('authorization_request_event.changelog_entry_applicant_with_missing_data')
    end
  end

  def initial_submit?
    object.authorization_request.events.where(name: 'submit').order(created_at: :asc).first == object
  end

  def initial_submit_with_changed_prefilled?
    initial_submit? &&
      (
        from_form_with_prefilled_data_with_changes? ||
          authorization_request_is_a_copy?
      )
  end

  def authorization_request_is_a_copy?
    authorization_request.events.exists?(name: 'copy')
  end

  def from_form_with_prefilled_data_with_changes?
    object.authorization_request.form.prefilled? &&
      prefilled_changed?
  end

  def prefilled_changed?
    object.authorization_request.form.data.any? do |key, value|
      object.authorization_request.public_send(key) != value
    end
  end
end
