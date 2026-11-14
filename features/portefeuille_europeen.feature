# language: fr

Fonctionnalité: Page publique Portefeuille européen
  En tant qu’organisation qui demandera des données au portefeuille européen,
  je comprends si je dois m’enregistrer au registre, comment, et ce qu’il publiera.

  Scénario: Avant l’ouverture, un visiteur voit la page et peut demander à être prévenu
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Alors le titre de la page est "Portefeuille européen - DataPass"
    Et il y a un titre contenant "Le portefeuille européen et son registre"
    Et le fil d’Ariane mène de « Accueil » à « Portefeuille européen »
    Et l’entrée du menu « Portefeuille européen » est la page courante
    Et les sections de la page se suivent dans cet ordre :
      | Le portefeuille européen et son registre      |
      | Les acteurs du portefeuille européen          |
      | Ce qui vous concerne                          |
      | Calendrier                                    |
      | Questions fréquentes                          |
      | Être prévenu de l’ouverture du registre       |
    Et la page contient un lien "Être prévenu de l’ouverture" vers "/portefeuille-europeen#etre-prevenu"
    Et la page contient "Le registre ouvre le 24 décembre 2026."
    Et la page contient "Une entreprise ou une administration qui demandera des données"
    Et la page ne contient pas "Enregistrer mon organisation"
    Et la page ne contient pas "Le registre des parties utilisatrices du portefeuille européen ouvre le 24 décembre 2026."

  @registre_ouvert
  Scénario: À l’ouverture, le bouton « Enregistrer mon organisation » remplace « Être prévenu »
    Sachant que le registre du portefeuille européen est ouvert
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Alors la page contient un lien "Enregistrer mon organisation" vers "/portefeuille-europeen#etapes"
    Et la page ne contient pas "Le registre ouvre le 24 décembre 2026."
    Et la page ne contient pas de lien "Être prévenu de l’ouverture"
    Et la page contient un lien "Être prévenu" vers "/portefeuille-europeen#etre-prevenu"
    Et il y a un titre contenant "Être prévenu de l’ouverture de votre formulaire"
    Et la page ne contient pas "Une entreprise ou une administration qui demandera des données"
    Et la page contient "Un intermédiaire ou un éditeur de logiciel"
    Et la page contient "Un fournisseur d’attestations"

  Scénario: Les trois liens de l’accueil mènent à la page Portefeuille européen
    Quand je me rends sur la page d'accueil
    Alors l'en-tête contient un lien "Portefeuille européen" vers "/portefeuille-europeen"
    Et la tuile "Votre organisation et le portefeuille européen" mène à "/portefeuille-europeen"
    Et l’encart de l’accueil mène à "/portefeuille-europeen"

  Scénario: L’onglet Organisations est ouvert par défaut et rappelle l’habilitation
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Alors l’onglet « Organisations » est sélectionné
    Et l’onglet « Organisations » contient une mise en avant "vous demandez toujours l’habilitation correspondante"

  @javascript
  Scénario: Un lien vers l’onglet Particuliers ouvre cet onglet
    Quand je me rends sur le chemin "/portefeuille-europeen#tab-particuliers-panel"
    Alors l’onglet « Particuliers » est sélectionné
    Et la page contient "Qui peut vous demander accès à vos données ?"

  Scénario: Les liens vers des pages pas encore livrées mènent à une cible provisoire de la page
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Alors la page ne contient pas de lien "Consulter le registre public"
    Et la page contient un lien "Lire la politique d’enregistrement" vers "/portefeuille-europeen#questions"

  Scénario: Le bloc « Être prévenu » ne transmet aucune adresse
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Alors le bloc « Être prévenu » ne contient pas de formulaire et son champ d’adresse n’a pas de nom
