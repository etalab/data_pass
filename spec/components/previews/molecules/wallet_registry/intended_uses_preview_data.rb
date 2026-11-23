# Données des previews de l’étape « Les utilisations prévues » du registre wallet : une demande de la Ville de Clamart
# (seeds) et des utilisations construites en mémoire sur les attestations du référentiel (PID et permis de conduire),
# jamais enregistrées. Les identifiants sont posés à la main : les boutons et les modales en ont besoin.
module Molecules::WalletRegistry::IntendedUsesPreviewData
  private

  def draft_request
    AuthorizationRequest::RegistreWallet.new(
      id: 1,
      organization: Organization.find_by!(legal_entity_id: '21920023500014'),
      form_uid: 'registre-wallet',
      wallet_service_name: 'Vélocité Libre-service',
      wallet_privacy_policy_url: 'https://www.clamart.fr/confidentialite'
    )
  end

  def majority_use(authorization_request = draft_request, claims: %w[age_over_18])
    build_use(authorization_request, id: 1, name: 'Vérifier la majorité', purpose: 'Vérifier que vous avez plus de 18 ans avant de vous louer un vélo.').tap do |use|
      add_attestation(use, 'mdl', claims:, id: 1)
    end
  end

  def account_use(authorization_request = draft_request, claims: %w[family_name given_name nationality])
    build_use(authorization_request, id: 2, name: 'Ouvrir un compte client', purpose: 'Ouvrir votre compte client sans retaper vos informations.',
      end_date: Date.current + 365, privacy_policy_url: 'https://www.clamart.fr/compte-client').tap do |use|
      add_attestation(use, 'pid', claims:, id: 2)
    end
  end

  def blank_use(authorization_request = draft_request)
    build_use(authorization_request, id: 3, name: nil, purpose: nil, start_date: nil)
  end

  def build_use(authorization_request, id:, start_date: Date.current, **)
    authorization_request.wallet_intended_uses.build(id:, start_date:, **)
  end

  def add_attestation(use, identifier, claims:, id:)
    rulebook = rulebook(identifier)
    use.add_attestation(rulebook).tap do |attestation|
      attestation.id = id
      attestation.selected_claim_ids = rulebook.claims.where(identifier: claims).ids
    end
  end

  def rulebook(identifier)
    WalletRegistry::Rulebook.available.find_by!(identifier:)
  end
end
