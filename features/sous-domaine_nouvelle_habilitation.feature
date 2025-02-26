# language: fr

Fonctionnalité: Démarrage d'une habilitation en fonction du sous-domaine.
  Il est possible de démarrer une habilitation depuis le tableau de bord via le bouton "Nouvelle habilitation",
  son comportement peut changer en fonction du sous-domaine utilisé.

  Contexte:
    Sachant que je suis un demandeur

  Scénario: Je peux démarrer n'importe quel type de demande sur le sous-domaine principal
    Sachant que je me connecte
    Et que je clique sur "Nouvelle habilitation"
    Alors la page contient "Demander une nouvelle habilitation"
    Et la page contient "API Entreprise"
    Et la page contient "API Particulier"
    Et la page contient "API scolarité de l'élève"

  Scénario: Je peux démarrer uniquement les demandes référencés dans la configuration de sous-domaine
    Sachant que je consulte le site ayant le sous-domaine "api-gouv"
    Et que je me connecte
    Et que je clique sur "Nouvelle habilitation"
    Alors la page contient "Demander une nouvelle habilitation"
    Et la page contient "API Entreprise"
    Et la page contient "API Particulier"
    Et la page ne contient pas "API scolarité de l'élève"

  Scénario: Dans le cas où seul 1 demande est possible, je suis immédiatement redirigé sur la page de cette demande
    Sachant que je consulte le site ayant le sous-domaine "api-entreprise"
    Et que je me connecte
    Et que je clique sur "Nouvelle habilitation"
    Alors la page contient "Demander une habilitation à : API Entreprise"
    Et la page ne contient pas "API Particulier"
