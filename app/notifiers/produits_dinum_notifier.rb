class ProduitsDinumNotifier < BaseNotifier
  def approve(params)
    super

    transmit_convention_to_referent
  end

  private

  def transmit_convention_to_referent
    return if authorization_request.contact_technique_email.blank?

    ProduitsDinumMailer.with(
      authorization_request:,
    ).transmit_convention.deliver_later
  end
end
