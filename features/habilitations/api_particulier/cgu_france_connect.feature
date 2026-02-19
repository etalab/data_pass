# language: fr

Fonctionnalité: Affichage des CGU FranceConnect dans le formulaire API Particulier
  Les CGU de FranceConnect doivent apparaître dans la case à cocher
  quand la modalité FranceConnect est sélectionnée et que le formulaire est certifié FranceConnect.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: La case CGU affiche les deux liens quand la modalité FranceConnect est sélectionnée avec un formulaire certifié
    Sachant que j'ai une demande API Particulier certifiée FranceConnect avec modalité FranceConnect en cours de remplissage
    Quand je me rends sur le résumé de cette demande
    Alors la page contient "conditions générales d’utilisation de l’API Particulier"
    Et la page contient "conditions générales d’utilisation de FranceConnect"

  Scénario: La case CGU affiche un seul lien quand la modalité FranceConnect n'est pas sélectionnée
    Sachant que j'ai une demande API Particulier certifiée FranceConnect sans modalité FranceConnect en cours de remplissage
    Quand je me rends sur le résumé de cette demande
    Alors la page contient "conditions générales d’utilisation"
    Et la page ne contient pas "conditions générales d’utilisation de FranceConnect"
