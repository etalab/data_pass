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
    @reified_data ||= reified_data_as_array.compact.to_h
  end

  def reified_data_as_array
    authorization_request_data_keys.map do |key|
      newest_diff = previous_changelog_diffs.find { |diff| diff[key].present? }

      [key, newest_diff[key].last] if newest_diff
    end
  end

  def initial_diff_with_prefilled_form
    authorization_request_data_keys.to_h do |attribute|
      default_value = authorization_request.form.data[attribute.to_sym]
      actual_value = authorization_request_value_for_diff(attribute)

      if data_changed_between_prefilling_and_submit?(default_value, actual_value)
        [attribute, [default_value, actual_value]]
      elsif default_value.present?
        [attribute, [default_value, default_value]]
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
    if document_key?(key)
      document_value_for_diff(key)
    else
      authorization_request.public_send(key)
    end
  end

  def document_key?(key)
    authorization_request.class.documents.map { |document| document.name.to_s }.include?(key.to_s)
  end

  def document_value_for_diff(key)
    document_type = authorization_request.class.documents.find { |document| document.name == key.to_sym }
    attachment = authorization_request.public_send(key)

    if document_type.multiple?
      Array(attachment).map(&:filename).join(', ').presence
    else
      attachment&.filename
    end
  end

  def previous_changelog_diffs
    @previous_changelog_diffs ||= authorization_request.changelogs.order(created_at: :desc).pluck(:diff)
  end

  def create_changelog(diff)
    context.changelog = authorization_request.changelogs.create!(
      diff:
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
    authorization_request.class.documents.map { |document| document.name.to_s }
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
    @authorization_request ||= context.authorization_request.object
  rescue NoMethodError
    @authorization_request ||= context.authorization_request
  end
end
