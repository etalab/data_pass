class ProduitsDinumNotifier < BaseNotifier
  def approve(params)
    super

    transmit_convention unless notification_policy.suppress?('produits_dinum_convention')
  end

  private

  def transmit_convention
    ProduitsDinumMailer.with(
      authorization_request:,
    ).transmit_convention.deliver_later
  end
end
