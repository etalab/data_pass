# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Impôts Particuliers avec éditeur
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

    Quand je veux remplir une demande pour "API Impôt Particulier" via le formulaire "API Impôt Particulier avec éditeur"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

  Scénario: Je ne choisis aucune modalité d'appel
    Quand je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "La modalité d'accès aux données doit être rempli(e)"

  Scénario: Je choisis la modalité via le numéro fiscal
    Quand je choisis "Via le numéro fiscal (SPI)"
    Et que je clique sur "Suivant"
    Alors la page contient "Quelles sont les données dont vous avez besoin ?"
  
  Scénario: Je choisis la modalité via l'état civil
    Quand je choisis "Via l'état civil"
    Et que je clique sur "Suivant"
    Alors la page contient "Quelles sont les données dont vous avez besoin ?"
   
  Scénario: Je choisis la modalité FranceConnect alors que je n'ai pas d'habilitation FranceConnect
    Quand je choisis "Avec FranceConnect"
    Alors la page contient "il vous faudra au préalable demander une habilitation FranceConnect"
    Et la page ne contient pas "Sélectionnez une habilitation FranceConnect"
    Quand je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "L'habilitation FranceConnect doit être rempli(e)"
   
  Scénario: Je choisis la modalité FranceConnect alors que j'ai une habilitation FranceConnect
    Sachant que mon organisation a 1 demande d'habilitation "France Connect" validée
    Quand je rafraîchis la page
    Et que je choisis "Avec FranceConnect"
    Et que je clique sur "Suivant"
    Alors la page contient "Quelles sont les données dont vous avez besoin ?"