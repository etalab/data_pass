class SaveAuthorizationRequest < ApplicationInteractor
  def call
    @authorization_request_was_new = context.authorization_request.new_record?

    return if context.authorization_request.save(context: context.save_context)

    fail_with_error(:authorization_request_invalid, errors: context.authorization_request.errors.full_messages)
  end

  def rollback
    return unless @authorization_request_was_new

    context.authorization_request.destroy if context.authorization_request&.persisted?
  end
end
