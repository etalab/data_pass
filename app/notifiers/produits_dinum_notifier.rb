class ProduitsDinumNotifier < BaseNotifier
  def approve(params)
    super

    notification_policy.deliver('produits_dinum_convention') { transmit_convention }
  end

  private

  def transmit_convention
    ProduitsDinumMailer.with(
      authorization_request:,
    ).transmit_convention.deliver_later
  end
end
