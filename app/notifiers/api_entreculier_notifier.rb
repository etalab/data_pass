class APIEntreculierNotifier < ApplicationNotifier
  AuthorizationRequest.state_machine.states.each do |state|
    # rubocop:disable Lint/EmptyBlock
    define_method(state.name) do |_params|
    end
    # rubocop:enable Lint/EmptyBlock
  end

  def validated(_params)
    deliver_gdpr_emails

    RegisterOrganizationWithContactsOnCRMJob.perform_later(authorization_request.id)
  end

  def submitted(_params)
    Instruction::AuthorizationRequestMailer.with(
      authorization_request:
    ).submitted.deliver_later
  end
end
