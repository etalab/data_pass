# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation Produits DINUM
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que je démarre une nouvelle demande d'habilitation "Produits DINUM"

  Scénario: Je soumets une demande valide avec une URL de cadre juridique
    * je remplis "Nature juridique de votre structure" avec "Établissement public administratif"
    * je remplis "Veuillez nous indiquer l’url du texte vous autorisant à accéder aux produits DINUM" avec "https://exemple.gouv.fr/cadre-juridique"
    * je clique sur "Suivant"

    * je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Email                  | Téléphone   | Fonction |
      | Dupont | Jacques | dupont.jacques@gouv.fr | 0436656565  | Délégué  |
    * je remplis les informations du contact "Responsable de l’administration" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction    |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0336656565  | Responsable |
    * je remplis les informations du contact "Contact référent des outils numériques de l’administration" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction  |
      | Dupont | Marc   | dupont.marc@gouv.fr | 0136656565  | Technique |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"

  Scénario: Je soumets une demande valide avec un document justificatif
    * je remplis "Nature juridique de votre structure" avec "Établissement public administratif"
    * je remplis "Fournissez un document justifiant que vous pouvez accéder à ces produits" avec le fichier "spec/fixtures/dummy.pdf"
    * je clique sur "Suivant"

    * je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Email                  | Téléphone   | Fonction |
      | Dupont | Jacques | dupont.jacques@gouv.fr | 0436656565  | Délégué  |
    * je remplis les informations du contact "Responsable de l’administration" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction    |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0336656565  | Responsable |
    * je remplis les informations du contact "Contact référent des outils numériques de l’administration" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction  |
      | Dupont | Marc   | dupont.marc@gouv.fr | 0136656565  | Technique |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"

  Scénario: Le cadre juridique est bloqué sans URL ni document justificatif
    * je remplis "Nature juridique de votre structure" avec "Établissement public administratif"
    * je clique sur "Suivant"

    Alors il y a au moins une erreur sur un champ
