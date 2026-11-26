module WalletRegistryStartHelper
  def wallet_registry_start(definition)
    WalletRegistryStart.new(
      answer: params[:parcours],
      violation: (policy(definition).access_violation if user_signed_in?),
      verification: flash[:dirigeant_verification],
      organization: current_organization,
      signed_in: user_signed_in?
    )
  end

  def wallet_registry_return_path(definition, start)
    new_authorization_request_path(definition_id: definition.id, parcours: start.answer)
  end

  def wallet_registry_change_answer_path(definition)
    new_authorization_request_path(definition_id: definition.id, changer_de_reponse: (true if user_signed_in?))
  end
end
