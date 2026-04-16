module AuthorizationRequestPermittedKeys
  extend ActiveSupport::Concern

  private

  def authorization_request_class
    authorization_request_form.authorization_request_class
  end

  def authorization_request_form
    context.authorization_request_form ||
      context.authorization_request.form
  end

  def permitted_extra_attributes
    authorization_request_class.extra_attributes.map(&:to_sym)
  end

  def permitted_documents
    authorization_request_class.documents.map(&:permitted_attribute)
  end

  def permitted_scopes
    return [] unless authorization_request_class.scopes_enabled?

    [{ scopes: [] }]
  end

  def permitted_modalities
    [{ modalities: [] }]
  end

  def permitted_build_step
    return [] unless authorization_request_form.multiple_steps?

    [:current_build_step]
  end

  def permitted_contacts
    authorization_request_class.contact_types.each_with_object([]) do |contact_type, attributes|
      attributes.concat(
        authorization_request_class.contact_attributes.map { |attribute| :"#{contact_type}_#{attribute}" }
      )
    end
  end

  def extract_permitted_attributes
    %i[
      extra_attributes
      documents
      scopes
      build_step
      contacts
      modalities
    ].each_with_object([]) do |method, attributes|
      attributes.concat(send(:"permitted_#{method}"))
    end
  end
end
