class RejectHoneypotSubmission < ApplicationInteractor
  def call
    return if context.honeypot.blank?

    Rails.logger.info('[european-wallet-subscription] champ piège rempli, inscription ignorée')
    context.fail!(spam: true)
  end
end
