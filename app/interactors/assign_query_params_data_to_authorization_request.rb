class AssignQueryParamsDataToAuthorizationRequest < ApplicationInteractor
  def call
    return if prefill_data.blank?

    filtered_data.each do |name, value|
      context.authorization_request.public_send(:"#{name}=", value)
    rescue StandardError
      next
    end
  end

  private

  def prefill_data
    context.prefill_data
  end

  def filtered_data
    prefill_data.to_h.stringify_keys.slice(*allowed_attribute_names)
  end

  def allowed_attribute_names
    context.authorization_request.class.prefillable_attribute_names
  end
end
