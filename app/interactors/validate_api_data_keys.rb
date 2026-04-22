class ValidateAPIDataKeys < ApplicationInteractor
  include AuthorizationRequestPermittedKeys

  def call
    return if invalid_keys.empty?

    fail_with_error(:invalid_data_keys, errors: invalid_keys, format: :data_keys)
  end

  private

  def invalid_keys
    submitted_keys - valid_keys
  end

  def submitted_keys
    context.authorization_request_params.keys.map(&:to_s)
  end

  def valid_keys
    extract_permitted_attributes.flat_map { |attr| Array(attr.try(:keys) || attr).map(&:to_s) }
  end
end
