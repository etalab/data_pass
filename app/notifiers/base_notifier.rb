class BaseNotifier < ApplicationNotifier
  %w[
    changes_requested
    refused
  ].each do |event|
    define_method(event) do |params|
      if authorization_request.already_been_validated?
        email_notification("reopening_#{event}", params)
      else
        email_notification(event, params)
      end
    end
  end

  def validated(params)
    if params[:first_validation]
      email_notification('validated', params)
    else
      email_notification('reopening_validated', params)
    end
  end

  def submitted(_params)
    Instruction::AuthorizationRequestMailer.with(
      authorization_request:
    ).submitted.deliver_later
  end

  %w[
    draft
    archived
  ].each do |event|
    # rubocop:disable Lint/EmptyBlock
    define_method(event) do |params|
    end
    # rubocop:enable Lint/EmptyBlock
  end
end
