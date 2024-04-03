class APIEntrepriseNotifier < ApplicationNotifier
  AuthorizationRequest.state_machine.states.each do |state|
    # rubocop:disable Lint/EmptyBlock
    define_method(state.name) do |_params|
    end
    # rubocop:enable Lint/EmptyBlock
  end

  def submitted(_params)
    Instruction::AuthorizationRequestMailer.with(
      authorization_request:
    ).submitted.deliver_later
  end
end
