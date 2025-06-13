# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Particulier avec les modalités
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Demande libre"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

  Scénario: Je choisis la modalité FranceConnect alors que je n'ai pas d'habilitation FranceConnect
    Quand je coche "Via FranceConnect"
    Alors la page contient "il vous faudra au préalable demander une habilitation FranceConnect"
    Et la page ne contient pas "Sélectionnez une habilitation FranceConnect"
    Quand je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "L'habilitation FranceConnect doit être rempli(e)"

  Scénario: Je choisis la modalité FranceConnect alors que j'ai une habilitation FranceConnect
    Sachant que mon organisation a 1 demande d'habilitation "FranceConnect" validée
    Quand je rafraîchis la page
    Et que je coche "Via FranceConnect"
    Et que je clique sur "Suivant"
    Alors la page contient "Quelles sont les données dont vous avez besoin ?"

  Scénario: Je ne vois pas la modalité Formulaire national QF
    Alors la page ne contient pas "formulaire national QF"
    Et la page contient "Comment vos usagers accèderont aux données ?"
