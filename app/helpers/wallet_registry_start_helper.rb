module WalletRegistryStartHelper
  def wallet_registry_answer_key
    return 'dirigeant_without_certification' if wallet_registry_answer == 'dirigeant' && !FeatureFlag.enabled?(:proconnect_dirigeant)

    wallet_registry_answer
  end

  def wallet_registry_sign_in_locals
    locals = { return_to: wallet_registry_return_path, title: nil, wrapper_class: nil }

    return locals unless wallet_registry_executive_sign_in?
    return locals.merge(hidden_fields: { parcours: 'dirigeant' }) unless user_signed_in?

    locals.merge(identity_federator: 'proconnect_dirigeant', hidden_fields: { siret_hint: current_organization&.siret })
  end

  private

  def wallet_registry_executive_sign_in?
    wallet_registry_answer == 'dirigeant' && FeatureFlag.enabled?(:proconnect_dirigeant)
  end
end
