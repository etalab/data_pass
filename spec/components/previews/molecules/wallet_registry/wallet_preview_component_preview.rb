# @label Aperçu du wallet (étape « Les utilisations prévues » du registre wallet)
#
# Ce que l’usager verra dans son wallet pour une utilisation prévue : le service, les données demandées par
# attestation, la finalité et la politique de confidentialité. À partir de deux utilisations, une liste déroulante
# choisit l’utilisation affichée ; sur la page, l’aperçu suit aussi l’utilisation ouverte ou parcourue.
#
# **Où** : registre wallet, étape 3, colonne de droite.
class Molecules::WalletRegistry::WalletPreviewComponentPreview < ApplicationPreview
  include Molecules::WalletRegistry::IntendedUsesPreviewData

  # @label 1. Aucune utilisation
  def empty
    render_preview(draft_request, [])
  end

  # @label 2. Une utilisation sans finalité ni donnée
  def unwritten_use
    use = blank_use

    render_preview(use.authorization_request, [use])
  end

  # @label 3. Une utilisation remplie, politique de l’organisation
  def filled_use
    use = majority_use

    render_preview(use.authorization_request, [use])
  end

  # @label 4. Deux utilisations, la seconde affichée avec sa propre politique
  def two_uses
    authorization_request = draft_request
    uses = [majority_use(authorization_request), account_use(authorization_request)]

    render_preview(authorization_request, uses, previewed_use: uses.last)
  end

  # @label 5. Nom du service pas encore saisi
  def without_service_name
    use = majority_use
    use.authorization_request.wallet_service_name = nil

    render_preview(use.authorization_request, [use])
  end

  private

  def render_preview(authorization_request, uses, previewed_use: nil)
    render Molecules::WalletRegistry::WalletPreviewComponent.new(authorization_request:, uses:, previewed_use:)
  end
end
