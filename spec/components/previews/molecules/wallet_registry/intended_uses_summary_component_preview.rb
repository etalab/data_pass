# @label Utilisations prévues au récapitulatif (registre wallet)
#
# Le bloc « Les utilisations prévues des données » du récapitulatif : pour chaque utilisation, sa finalité, sa
# période, sa politique de confidentialité et ses données par attestation, puis le nombre de certificats
# d’enregistrement qui seront délivrés.
#
# **Où** : registre wallet, récapitulatif avant soumission, et consultation de la demande.
class Molecules::WalletRegistry::IntendedUsesSummaryComponentPreview < ApplicationPreview
  include Molecules::WalletRegistry::IntendedUsesPreviewData

  # @label 1. Aucune utilisation
  def empty
    render_summary(draft_request)
  end

  # @label 2. Une utilisation complète, sans date de fin, politique de l’organisation
  def one_use
    render_summary(majority_use.authorization_request)
  end

  # @label 3. Une utilisation sans nom, finalité, période ni donnée
  def unwritten_use
    render_summary(blank_use.authorization_request)
  end

  # @label 4. Deux utilisations, la seconde avec une date de fin et sa propre politique
  def two_uses
    authorization_request = draft_request
    majority_use(authorization_request)
    account_use(authorization_request)

    render_summary(authorization_request)
  end

  private

  def render_summary(authorization_request)
    render Molecules::WalletRegistry::IntendedUsesSummaryComponent.new(authorization_request:, uses: authorization_request.wallet_intended_uses.to_a)
  end
end
