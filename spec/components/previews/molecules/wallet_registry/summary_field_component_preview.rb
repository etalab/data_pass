# @label Information du récapitulatif (registre wallet)
#
# Une information du récapitulatif : libellé petit et gris, valeur en gras, dans une colonne de la grille DSFR.
#
# **Où** : registre wallet, récapitulatif avant soumission et consultation de la demande.
class Molecules::WalletRegistry::SummaryFieldComponentPreview < ApplicationPreview
  # @label 1. Valeur courte, sur un tiers de la largeur
  def third
    render Molecules::WalletRegistry::SummaryFieldComponent.new(label: 'Numéro de SIRET', value: '219 200 235 00014')
  end

  # @label 2. Valeur sur plusieurs lignes, sur la moitié de la largeur
  def half
    render Molecules::WalletRegistry::SummaryFieldComponent.new(label: 'Assistance aux usagers', width: :half) do
      safe_join(['https://www.clamart.fr/aide', 'contact@clamart.fr'], tag.br)
    end
  end
end
