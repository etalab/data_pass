# @label Données demandées d’une utilisation (étape « Les utilisations prévues » du registre wallet)
#
# Section « Données demandées » d’une utilisation prévue : totaux, attestations demandées (la première ouverte, ou
# celle en erreur) et bouton « Ajouter une attestation », qui ouvre le catalogue.
#
# **Où** : registre wallet, étape 3, dans chaque utilisation, entre la finalité et la période.
class Organisms::WalletRegistry::IntendedUseDataComponentPreview < ApplicationPreview
  include Molecules::WalletRegistry::IntendedUsesPreviewData

  # @label 1. Aucune attestation
  def without_attestation
    render_data(blank_use)
  end

  # @label 2. Aucune attestation, erreur après « Suivant »
  def without_attestation_error
    use = blank_use
    use.validate

    render_data(use)
  end

  # @label 3. Une attestation
  def one_attestation
    render_data(majority_use)
  end

  # @label 4. Deux attestations, la seconde ouverte depuis le catalogue
  def two_attestations
    use = majority_use
    pid = add_attestation(use, 'pid', claims: %w[family_name given_name], id: 2)

    render_data(use, focus_key: "attestation_#{pid.rulebook_id}")
  end

  private

  def render_data(use, focus_key: nil)
    render_with_template(template: 'organisms/wallet_registry/intended_use_data_component_preview/in_fieldset',
      locals: { component: Organisms::WalletRegistry::IntendedUseDataComponent.new(use:, index: 0, focus_key:) })
  end
end
