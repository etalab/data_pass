# language: fr

Fonctionnalité: Soumission d'une demande Produits DINUM avec le bloc legal_dinum

  Scénario: Je soumets une demande Produits DINUM valide en renseignant une URL
    Sachant que je suis un demandeur
    Et que je me connecte
    Et qu'un type d'habilitation « Produits DINUM » expose le bloc « legal_dinum »

    Quand je démarre une nouvelle demande d'habilitation "Produits DINUM"

    * je remplis "Nature juridique de votre structure" avec "Établissement public administratif"
    * je remplis "Veuillez nous indiquer l’url du texte vous autorisant à accéder aux produits DINUM" avec "https://legifrance.gouv.fr/loi-dinum"
    * je clique sur "Suivant"
    * la page contient "Contact référent des outils numériques"

    * je renseigne les informations du délégué à la protection des données
    * je remplis les informations du contact "Responsable de l’administration" avec :
      | Nom    | Prénom | Email               | Téléphone  | Fonction               |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0336656565 | Responsable administration |
    * je remplis les informations du contact "Contact référent des outils numériques" avec :
      | Nom    | Prénom | Email                 | Téléphone  | Fonction            |
      | Martin | Sophie | sophie.martin@gouv.fr | 0636656565 | Référente numérique |
    * je clique sur "Suivant"

    * je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    * je coche "conditions générales"
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"

  Scénario: Je soumets une demande Produits DINUM valide en joignant un document
    Sachant que je suis un demandeur
    Et que je me connecte
    Et qu'un type d'habilitation « Produits DINUM » expose le bloc « legal_dinum »

    Quand je démarre une nouvelle demande d'habilitation "Produits DINUM"

    * je remplis "Nature juridique de votre structure" avec "Établissement public administratif"
    * je remplis "Fournissez un document justifiant que vous pouvez accéder à ces produits" avec le fichier "spec/fixtures/dummy.pdf"
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je remplis les informations du contact "Responsable de l’administration" avec :
      | Nom    | Prénom | Email               | Téléphone  | Fonction               |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0336656565 | Responsable administration |
    * je remplis les informations du contact "Contact référent des outils numériques" avec :
      | Nom    | Prénom | Email                 | Téléphone  | Fonction            |
      | Martin | Sophie | sophie.martin@gouv.fr | 0636656565 | Référente numérique |
    * je clique sur "Suivant"

    * je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    * je coche "conditions générales"
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"

  Scénario: Le cadre juridique bloque la demande si ni URL ni document n'est renseigné
    Sachant que je suis un demandeur
    Et que je me connecte
    Et qu'un type d'habilitation « Produits DINUM » expose le bloc « legal_dinum »

    Quand je démarre une nouvelle demande d'habilitation "Produits DINUM"

    * je remplis "Nature juridique de votre structure" avec "Établissement public administratif"
    * je clique sur "Suivant"

    Alors il y a au moins une erreur sur un champ
