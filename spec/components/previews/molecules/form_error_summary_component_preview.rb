# @label Bandeau « points à corriger avant de continuer »
#
# Liste en tête d’étape les erreurs de la saisie, chacune avec un lien vers son champ. Le bandeau
# reçoit le focus à l’affichage, pour qu’un lecteur d’écran l’annonce.
#
# **Où** : registre wallet, étapes du formulaire, au clic sur « Suivant » quand l’étape est incomplète.
class Molecules::FormErrorSummaryComponentPreview < ApplicationPreview
  # @label 1. Deux points à corriger
  def two_errors
    render Molecules::FormErrorSummaryComponent.new(record: invalid_draft)
  end

  # @label 2. Un seul point
  def one_error
    draft = invalid_draft(wallet_support_email: 'contact@clamart.fr')

    render Molecules::FormErrorSummaryComponent.new(record: draft)
  end

  private

  def invalid_draft(attributes = {})
    draft = AuthorizationRequest::RegistreWallet.new(
      organization: Organization.find_by!(legal_entity_id: '21920023500014'),
      applicant: User.find_by!(email: 'dem-commune@yopmail.com'),
      form_uid: 'registre-wallet',
      wallet_not_registered_elsewhere: true,
      **attributes
    )
    draft.current_build_step = 'wallet_organization'
    draft.validate
    draft
  end
end
