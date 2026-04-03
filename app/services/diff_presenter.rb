class DiffPresenter
  include ActionView::Helpers::SanitizeHelper

  delegate :t, to: I18n

  attr_reader :authorization_request

  def initialize(diff, authorization_request)
    @diff = diff
    @authorization_request = authorization_request
  end

  def entries
    build_entries(filtered_diff)
  end

  private

  def filtered_diff
    @diff.reject { |_, values| values[0] == values[1] }
  end

  def build_entries(diffs)
    diffs.map { |attribute, values|
      values = sanitize_values(attribute, values)

      case attribute
      when 'scopes'
        build_scopes_change(values)
      when 'modalities'
        build_modalities_change(values)
      when 'applicant_id'
        build_applicant_change(attribute, values)
      else
        build_attribute_change(attribute, values)
      end
    }.flatten
  end

  def sanitize_values(attribute, values)
    case attribute
    when 'scopes', 'modalities'
      values.map do |scopes|
        sanitize_values('scope', Array(scopes))
      end
    else
      values.map do |value|
        sanitize(value)
      rescue NoMethodError
        value
      end
    end
  end

  def build_scopes_change(values)
    build_array_change('scope', values)
  end

  def build_modalities_change(values)
    build_array_change('modality', values)
  end

  def build_array_change(kind, values)
    initial_values = values[0] || []
    new_values = values[1] - initial_values
    removed_values = initial_values - values[1]

    [
      new_values.map do |value|
        t("authorization_request_event.changelog_entry_new_#{kind}", value: humanized_attribute(kind, value)).html_safe
      end,
      removed_values.map do |value|
        t("authorization_request_event.changelog_entry_removed_#{kind}", value: humanized_attribute(kind, value)).html_safe
      end
    ]
  end

  def humanized_attribute(attribute, value)
    send("humanized_#{attribute}", value)
  end

  def humanized_scope(scope_value)
    scope = authorization_request.definition.scopes.find { |s| s.value == scope_value }

    if scope
      [scope.name, "(#{scope_value})"].join(' ')
    else
      scope_value
    end
  end

  def humanized_modality(modality_value)
    I18n.t(
      "activerecord.values.#{authorization_request.model_name.to_s.underscore}.modalities.#{modality_value}",
      default: modality_value
    )
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
end
