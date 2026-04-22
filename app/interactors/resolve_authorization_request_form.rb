class ResolveAuthorizationRequestForm < ApplicationInteractor
  def call
    context.authorization_request_form = find_form

    fail_with_error(:form_not_found) unless context.authorization_request_form
    fail_with_error(:unauthorized_type) unless authorized_type?
  end

  private

  def find_form
    if context.form_uid.present?
      AuthorizationRequestForm.find(context.form_uid)
    elsif context.type.present?
      AuthorizationDefinition.find(context.type).default_form
    end
  rescue StaticApplicationRecord::EntryNotFound
    nil
  end

  def authorized_type?
    context.authorized_types.include?(context.authorization_request_form.authorization_request_class.name)
  end
end
