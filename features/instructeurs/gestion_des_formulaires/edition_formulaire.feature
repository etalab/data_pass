# language: fr

Fonctionnalité: Consultation des étapes d'un formulaire
  En tant qu'instructeur, je peux consulter la page des étapes d'un formulaire
  afin de visualiser les blocs qui le composent.

  Contexte:
    Soit un fournisseur de données "DINUM" existe
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte

  Scénario: J'accède à la page des étapes depuis le détail du formulaire
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Voir les étapes du formulaire"
    Alors la page contient "Voir les étapes du formulaire"
    Et la page contient "API Entreprise"

  Scénario: La page affiche les blocs du formulaire
    Quand je me rends sur la page des étapes du formulaire "API Entreprise"
    Alors la page contient "Introduction du formulaire"
    Et la page contient "Mon projet"
    Et la page contient "Le traitement des données personnelles"
    Et la page contient "Le cadre juridique"
    Et la page contient "Les données"
    Et la page contient "Les personnes impliquées"
    Et la page contient "Avant de soumettre la demande"

  Scénario: Aucun bouton « Modifier » n'est affiché sur les blocs
    Quand je me rends sur la page des étapes du formulaire "API Entreprise"
    Alors il n'y a pas de bouton "Modifier"

  Scénario: Un manager ne voit pas non plus de bouton « Modifier » sur les blocs
    Sachant que je suis un manager "API Entreprise"
    Quand je me rends sur la page des étapes du formulaire "API Entreprise"
    Alors il n'y a pas de bouton "Modifier"
