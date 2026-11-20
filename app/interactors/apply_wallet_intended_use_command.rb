class ApplyWalletIntendedUseCommand < ApplicationInteractor
  SEPARATOR = ':'.freeze

  def call
    name, use_id, rulebook_id = context.command.to_s.split(SEPARATOR, 3)
    return add_use if name == 'add_use'

    use = authorization_request.wallet_intended_use(use_id) || fail_with_error(:unknown_wallet_intended_use)
    apply(name, use, rulebook_id)
  end

  private

  def authorization_request
    context.authorization_request
  end

  def apply(name, use, rulebook_id)
    case name
    when 'remove_use' then remove_use(use)
    when 'add_attestation' then add_attestation(use, rulebook_id)
    when 'remove_attestation' then remove_attestation(use, rulebook_id)
    when 'open_catalog' then context.catalog_use = use
    else fail_with_error(:unknown_wallet_intended_use_command)
    end
  end

  def add_use
    focus_on(authorization_request.wallet_intended_uses.build, focus: 'name')
  end

  def remove_use(use)
    use.mark_for_destruction
    focus_on(nil, focus: 'add_use')
  end

  def add_attestation(use, rulebook_id)
    rulebook = WalletRegistry::Rulebook.available.find_by(id: rulebook_id) || fail_with_error(:unknown_wallet_rulebook)

    use.add_attestation(rulebook)
    focus_on(use, focus: "attestation_#{rulebook.id}")
  end

  def remove_attestation(use, rulebook_id)
    use.remove_attestation(rulebook_id) || fail_with_error(:unknown_wallet_rulebook)
    focus_on(use, focus: 'add_attestation')
  end

  def focus_on(use, focus:)
    context.opened_use = use
    context.focus = focus
  end
end
