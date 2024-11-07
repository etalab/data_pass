class AssignParamsToAuthorizationRequest < ApplicationInteractor
  def call
    context.authorization_request.assign_attributes(
      valid_authorization_request_params
    )

    return if context.authorization_request.valid?(context.save_context)

    context.fail!
  end

  private

  def authorization_request_class
    authorization_request_form.authorization_request_class
  end

  def authorization_request_form
    context.authorization_request_form ||
      context.authorization_request.form
  end

  def valid_authorization_request_params
    context.authorization_request_params.permit(
      extract_permitted_attributes.push(
        %i[
          terms_of_service_accepted
          data_protection_officer_informed
        ]
      )
    )
  end

  def extract_permitted_attributes
    %i[
      extra_attributes
      documents
      scopes
      build_step
      contacts
    ].each_with_object([]) do |method, attributes|
      attributes.concat(send(:"permitted_#{method}"))
    end
  end

  def permitted_extra_attributes
    authorization_request_class.extra_attributes.map(&:to_sym)
  end

  def permitted_documents
    authorization_request_class.documents.map(&:to_sym)
  end

  def permitted_scopes
    return [] unless authorization_request_class.scopes_enabled?

    [{ scopes: [] }]
  end

  def permitted_build_step
    return [] unless authorization_request_form.multiple_steps?

    [:current_build_step]
  end

  def permitted_contacts
    authorization_request_class.contacts.each_with_object([]) do |contact, attributes|
      attributes.concat(
        authorization_request_class.contact_attributes.map { |attribute| :"#{contact.type}_#{attribute}" },
        contact.options.fetch(:additional_attributes, []).map { |attribute| :"#{contact.type}_#{attribute[:name]}" }
      )
    end
  end
end
