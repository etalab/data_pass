class CreateAuthorizationRequestChangelog < ApplicationInteractor
  def call
    if authorization_request.changelogs.empty?
      create_initial_changelog
    else
      create_changelog_with_diff
    end
  end

  private

  def create_initial_changelog
    create_changelog(
      authorization_request_initial_diff
    )
  end

  def create_changelog_with_diff
    create_changelog(
      reified_data.each_with_object({}) do |(key, old_value), diff|
        next unless authorization_request.respond_to?(key)
        next if authorization_request_value_for_diff(key) == old_value

        diff[key] = [old_value, authorization_request_value_for_diff(key)]
      end
    )
  end

  def authorization_request_initial_diff
    if authorization_request.form.prefilled?
      initial_diff_with_prefilled_form
    else
      initial_diff_without_prefilled_form
    end
  end

  def reified_data
    @reified_data ||= latest_changelog.diff.each_with_object(authorization_request_data) do |(key, value), latest_data|
      latest_data[key] = value[1]
    end
  end

  def initial_diff_with_prefilled_form
    authorization_request_data_keys.to_h do |attribute|
      default_value = authorization_request.form.data[attribute.to_sym]
      actual_value = authorization_request_value_for_diff(attribute)

      if data_changed_between_prefilling_and_submit?(default_value, actual_value)
        [attribute, [default_value, actual_value]]
      else
        [attribute, [nil, actual_value]]
      end
    end
  end

  def data_changed_between_prefilling_and_submit?(default_value, actual_value)
    default_value.present? && default_value.to_s != actual_value.to_s
  end

  def initial_diff_without_prefilled_form
    authorization_request_data_keys.index_with { |k| [nil, authorization_request_value_for_diff(k)] }
  end

  def authorization_request_value_for_diff(key)
    if authorization_request.class.documents.include?(key.to_sym)
      authorization_request.public_send(key).filename
    else
      authorization_request.public_send(key)
    end
  end

  def latest_changelog
    @latest_changelog ||= authorization_request.changelogs.last
  end

  def create_changelog(diff)
    context.changelog = authorization_request.changelogs.create!(
      diff: diff.reject { |_, value| value[0].blank? && value[1].blank? }
    )
  end

  def authorization_request_data
    @authorization_request_data ||= authorization_request_data_keys.index_with { |k| authorization_request_value_for_diff(k) }
  end

  def authorization_request_data_keys
    authorization_request_data_extra_attributes_keys +
      authorization_request_data_documents_keys +
      authorization_request_data_contact_attributes_keys +
      authorization_request_data_scopes_key
  end

  def authorization_request_data_extra_attributes_keys
    authorization_request.class.extra_attributes.map(&:to_s)
  end

  def authorization_request_data_documents_keys
    authorization_request.class.documents.map(&:to_s)
  end

  def authorization_request_data_contact_attributes_keys
    authorization_request.class.contact_types.map { |contact_type|
      authorization_request.class.contact_attributes.map { |attribute| "#{contact_type}_#{attribute}" }
    }.flatten
  end

  def authorization_request_data_scopes_key
    if authorization_request.class.scopes_enabled?
      ['scopes']
    else
      []
    end
  end

  def authorization_request
    context.authorization_request
  end
end
