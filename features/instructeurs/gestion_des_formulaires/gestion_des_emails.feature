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

  Scénario: La page liste les emails automatiques regroupés par évènement
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Voir les emails automatiques"
    Alors la page contient "Soumission de la demande"
    Et la page contient "Validation de la demande"

  Scénario: Le corps des emails est affiché avec des valeurs d’exemple
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Voir les emails automatiques"
    Alors la page contient "[nom du demandeur]"
    Et la page contient "[demandeur]"

  Scénario: La page propose de consulter la variante de réouverture d’un email
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Voir les emails automatiques"
    Alors la page contient "Mise à jour"

  Scénario: Un manager voit le lien « Gérer les emails automatiques »
    Sachant que je suis un manager "API Entreprise"
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Gérer les emails automatiques"
    Alors la page contient "Gérer les emails automatiques"

  Scénario: Le nombre d’emails automatiques est affiché sur le détail du formulaire
    Quand je me rends sur le formulaire "API Entreprise"
    Alors la page contient "4 emails automatiques"
