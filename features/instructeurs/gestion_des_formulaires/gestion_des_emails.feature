# language: fr

Fonctionnalité: Gestion des emails automatiques d'un formulaire
  En tant qu'instructeur, je peux consulter la page des emails automatiques
  d'un formulaire.

  Contexte:
    Soit un fournisseur de données "DINUM" existe
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte

  Scénario: J'accède à la page des emails automatiques depuis le détail du formulaire
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Voir les emails automatiques"
    Alors la page contient "Voir les emails automatiques"
    Et la page contient "API Entreprise"

  Scénario: La page affiche un message indiquant que la fonctionnalité est en cours de développement
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Voir les emails automatiques"
    Alors la page contient "Fonctionnalité en cours de développement"
    Et la page contient "datapass@api.gouv.fr"

  Scénario: Un manager voit le lien « Gérer les emails automatiques »
    Sachant que je suis un manager "API Entreprise"
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Gérer les emails automatiques"
    Alors la page contient "Gérer les emails automatiques"
