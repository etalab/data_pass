# language: fr
Fonctionnalité: États vides du dashboard demandeur

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Onglet demandes vide - Affichage de l'état vide
    Quand je me rends sur mon tableau de bord demandes
    Alors la page contient "Vous n'avez pas encore de demandes en cours"
    Et la page contient un lien vers "data.gouv.fr/fr/dataservices"

  Scénario: Onglet habilitations vide - Affichage de l'état vide
    Quand je me rends sur mon tableau de bord habilitations
    Alors la page contient "Vous n'avez pas encore d'habilitations"
    Et la page contient un lien vers "data.gouv.fr/fr/dataservices"