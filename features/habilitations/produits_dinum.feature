# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation Produits DINUM
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que je démarre une nouvelle demande d'habilitation "Éligibilité d'accès aux produits et services mis à disposition par la DINUM"

  Scénario: Je soumets une demande valide avec une URL de cadre juridique
    * je remplis "Nature juridique de votre structure" avec "Établissement public administratif"
    * je remplis "Veuillez nous indiquer l’URL du texte justificatif" avec "https://exemple.gouv.fr/cadre-juridique"
    * je clique sur "Suivant"

    * je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Courriel               |
      | Dupont | Jacques | dupont.jacques@gouv.fr |
    * je remplis les informations du contact "Responsable de l’administration" avec :
      | Nom    | Prénom | Courriel            |
      | Dupont | Jean   | dupont.jean@gouv.fr |
    * je remplis les informations du contact "Contact référent des outils numériques de l’administration" avec :
      | Nom    | Prénom | Courriel            |
      | Dupont | Marc   | dupont.marc@gouv.fr |
    * je clique sur "Suivant"

    * je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    * je coche "Je confirme que le responsable de l’administration de mon organisation est informé de ma demande."
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"

  Scénario: Je soumets une demande valide avec un document justificatif
    * je remplis "Nature juridique de votre structure" avec "Établissement public administratif"
    * je remplis "Fournissez un document justificatif" avec le fichier "spec/fixtures/dummy.pdf"
    * je clique sur "Suivant"

    * je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Courriel               |
      | Dupont | Jacques | dupont.jacques@gouv.fr |
    * je remplis les informations du contact "Responsable de l’administration" avec :
      | Nom    | Prénom | Courriel            |
      | Dupont | Jean   | dupont.jean@gouv.fr |
    * je remplis les informations du contact "Contact référent des outils numériques de l’administration" avec :
      | Nom    | Prénom | Courriel            |
      | Dupont | Marc   | dupont.marc@gouv.fr |
    * je clique sur "Suivant"

    * je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    * je coche "Je confirme que le responsable de l’administration de mon organisation est informé de ma demande."
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"

  Scénario: Le cadre juridique est bloqué sans URL ni document justificatif
    * je remplis "Nature juridique de votre structure" avec "Établissement public administratif"
    * je clique sur "Suivant"

    Alors il y a au moins une erreur sur un champ

  @AvecCourriels
  Scénario: La convention est transmise au contact référent des outils numériques à la validation
    * je remplis "Nature juridique de votre structure" avec "Établissement public administratif"
    * je remplis "Veuillez nous indiquer l’URL du texte justificatif" avec "https://exemple.gouv.fr/cadre-juridique"
    * je clique sur "Suivant"

    * je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Courriel               |
      | Dupont | Jacques | dupont.jacques@gouv.fr |
    * je remplis les informations du contact "Responsable de l’administration" avec :
      | Nom    | Prénom | Courriel            |
      | Dupont | Jean   | dupont.jean@gouv.fr |
    * je remplis les informations du contact "Contact référent des outils numériques de l’administration" avec :
      | Nom    | Prénom | Courriel            |
      | Dupont | Marc   | dupont.marc@gouv.fr |
    * je clique sur "Suivant"

    * je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    * je coche "Je confirme que le responsable de l’administration de mon organisation est informé de ma demande."
    * je clique sur "Soumettre la demande d'habilitation"

    Quand un instructeur a validé la demande d'habilitation
    Alors un email est envoyé contenant "convention de mise à disposition" à "dupont.marc@gouv.fr"
