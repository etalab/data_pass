# @label En-tête d’habilitation
#
# Bandeau en haut de la page d’une habilitation : intitulé, badges d’état, alertes contextuelles et
# boutons d’action.
#
# **Où** : `authorizations/show` et le layout `authorization_with_tabs`.
#
# **Pour qui** : tout le monde, mais les boutons dépendent des droits de la personne connectée —
# réouvrir, transférer, révoquer et démarrer l’étape suivante passent chacun par une policy.
#
# Le fond est bleu pour une habilitation active, gris pour les états révoqué et obsolète
# (`header_background_class`). Aucun de ces scénarios ne montre le sous-en-tête d’origine, réservé à
# l’espace instruction : voir la preview « Origine de l’habilitation ».
class AuthorizationHeaderComponentPreview < ApplicationPreview
  # @label 1. Habilitation active
  #
  # Cas nominal vu par le demandeur : fond bleu, badge « Active » et les actions ouvertes à sa
  # demande.
  #
  # **Où** : haut de la page d’une habilitation (`authorizations/show`).
  def active
    authorization = Authorization.where(state: 'active').first!

    render AuthorizationHeaderComponent.new(authorization:, current_user: authorization.applicant)
  end

  # @label 2. Mention en tant que contact
  #
  # Vu par une personne qui n’a pas déposé la demande mais y est renseignée comme contact : un
  # encart rappelle à quel titre elle y figure.
  #
  # **Où** : haut de la page d’une habilitation (`authorizations/show`).
  def contact_mention
    contact_user = User.find_by!(email: 'user@yopmail.com')
    authorization_request = AuthorizationRequest
      .where(state: 'validated')
      .where("EXISTS (
      select 1
      from each(authorization_requests.data) as kv
      where kv.key like '%_email' and lower(kv.value) = ?
    )", contact_user.email)
      .first!

    render AuthorizationHeaderComponent.new(authorization: authorization_request.latest_authorization, current_user: contact_user)
  end

  # @label 3. Habilitation obsolète
  #
  # Version remplacée par une plus récente : fond gris, badge « Obsolète » et lien vers
  # l’habilitation qui lui succède.
  #
  # **Où** : haut de la page d’une habilitation (`authorizations/show`).
  def old_version
    authorization = Authorization.where(state: 'obsolete').first!

    render AuthorizationHeaderComponent.new(authorization:, current_user: authorization.request.applicant)
  end

  # @label 4. Habilitation révoquée
  #
  # Habilitation retirée par un instructeur : fond gris, badge « Révoquée », et accès au formulaire
  # de contact du support.
  #
  # **Où** : haut de la page d’une habilitation (`authorizations/show`).
  def revoked
    authorization = Authorization.where(state: 'revoked').first!

    render AuthorizationHeaderComponent.new(authorization:, current_user: authorization.applicant)
  end
end
