# @label Bloc de configuration d’un cas d’usage
#
# Encadré « Configuration » d’un cas d’usage : fournisseur de service associé (préfixé « Éditeur »
# ou « SaaS »), « Visible dans la liste des cas d’usage », « Démarrable par le demandeur » et «
# Formulaire en une seule page ».
#
# **Où** : espace instruction, page `instruction/forms/show`, juste sous l’en-tête.
#
# **Pour qui** : la page est soumise à `Instruction::AuthorizationDefinitionPolicy#show?`.
#
# Quand aucun fournisseur de service n’est rattaché, la première ligne affiche « Aucun fournisseur
# de service » en gris clair au lieu du nom en gras.
class Molecules::Instruction::Form::ConfigBlockComponentPreview < ApplicationPreview
  # @label 1. Cas d’usage « Marchés publics »
  #
  # Cas d’usage sans fournisseur de service rattaché : la première ligne affiche « Aucun fournisseur
  # de service » en gris clair au lieu d’un nom en gras, et « Formulaire en une seule page » est à
  # non.
  #
  # **Où** : espace instruction, fiche d’un cas d’usage (`instruction/forms/show`), juste sous
  # l’en-tête.
  def api_entreprise_marches_publics
    form = AuthorizationDefinition.find('api_entreprise').available_forms.find do |f|
      f.use_case == 'marches_publics'
    end
    render Molecules::Instruction::Form::ConfigBlockComponent.new(form:)
  end

  # @label 2. Cas d’usage « Socle de base DLNUF »
  #
  # Second cas d’usage du même formulaire. Attention : dans les seeds actuelles, sa configuration
  # est identique à celle du scénario 1, le rendu est donc le même. Pour voir un fournisseur de
  # service en gras, il faut un cas d’usage porteur d’un éditeur ou d’un SaaS.
  #
  # **Où** : espace instruction, fiche d’un cas d’usage (`instruction/forms/show`), juste sous
  # l’en-tête.
  def api_entreprise_socle_de_base
    form = AuthorizationDefinition.find('api_entreprise').available_forms.find do |f|
      f.uid == 'api-entreprise-socle-de-base'
    end
    render Molecules::Instruction::Form::ConfigBlockComponent.new(form:)
  end
end
