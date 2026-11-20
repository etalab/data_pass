class WalletRegistrySignIn
  attr_reader :answer

  def initialize(answer:, violation:, signed_in:, organization:, return_to:)
    @answer = answer
    @violation = violation
    @signed_in = signed_in
    @organization = organization
    @return_to = return_to
  end

  def executive_journey_open?
    FeatureFlag.enabled?(:proconnect_dirigeant)
  end

  def executive_sign_in?
    executive_journey_open? && (answer == 'dirigeant' || @violation == :executive_certification_required)
  end

  def answer_key
    return 'dirigeant_without_certification' if answer == 'dirigeant' && !executive_journey_open?

    answer
  end

  def pro_connect_locals
    locals = { return_to: @return_to, title: nil, wrapper_class: nil }

    return locals unless executive_sign_in?
    return locals.merge(hidden_fields: { parcours: 'dirigeant' }) unless @signed_in

    locals.merge(identity_federator: 'proconnect_dirigeant', hidden_fields: { siret_hint: @organization&.siret })
  end
end
