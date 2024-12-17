# language: fr

@javascript
Fonctionnalité: Choix de la modalité d'appel et du stage du formulaire API Impôt Particulier

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je veux remplir une demande pour "API Impôt Particulier"

  Scénario: J'ai déjà un éditeur qui a accès au bac à sable
    Et que je choisis "Via l'état civil"
    Et que je choisis "Oui, j'ai un éditeur qui a déjà accès au bac à sable"
    Et que je clique sur "Démarrer ma demande d’habilitation en production"
    Alors la page contient "API Impôt Particulier avec éditeur"

  Scénario: Je n'ai pas encore accès au bac à sable
    Et que je choisis "Via l'état civil"
    Et que je choisis "Non, nous n'avons pas d'éditeur avec accès au bac à sable"
    Et que je clique sur "Démarrer ma demande d’habilitation en bac à sable"
    Alors la page contient "Le bac à sable"

  Scénario: Je veux accéder à l'API via FranceConnect alors que je n'ai pas d'habilitation FranceConnect
    Et que je choisis "Avec FranceConnect"
    Alors la page contient "il vous faudra au préalable demander une habilitation FranceConnect"
    Et la page ne contient pas "Sélectionnez une habilitation FranceConnect"
    Et la page ne contient pas "Démarrer"

  Scénario: Je veux accéder à l'API via FranceConnect et j'ai déjà une habilitation FranceConnect
    Sachant que mon organisation a 1 demande d'habilitation "France Connect" validée
    Et que je rafraîchis la page
    Et que je choisis "Avec FranceConnect"
    Alors le champ "Sélectionnez une habilitation FranceConnect qui sera liée à cette demande" est rempli
    Quand je choisis "Oui, j'ai un éditeur qui a déjà accès au bac à sable"
    Et que je clique sur "Démarrer ma demande d’habilitation en production"
    Alors la page contient "API Impôt Particulier avec éditeur"

  Scénario: Je veux accéder à l'API via l'Etat civil, et mon choix est retenu une fois arrivé au bloc de modalités d'accès
    * je choisis "Via l'état civil"
    * je choisis "Oui, j'ai un éditeur qui a déjà accès au bac à sable"
    * je clique sur "Démarrer"
    * je clique sur "Débuter ma demande"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"
    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"
    * je renseigne le cadre légal
    * je clique sur "Suivant"
    Alors "Via l'état civil" est coché

  Scénario: Je veux accéder à l'API via FranceConnect, et mon choix est retenu une fois arrivé au bloc de modalités d'accès
    Sachant que mon organisation a 1 demande d'habilitation "France Connect" validée
    * je rafraîchis la page
    * je choisis "Avec FranceConnect"
    * je choisis "Oui, j'ai un éditeur qui a déjà accès au bac à sable"
    * je clique sur "Démarrer"
    * je clique sur "Débuter ma demande"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"
    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"
    * je renseigne le cadre légal
    * je clique sur "Suivant"
    Alors "Avec FranceConnect" est coché
    Et le champ "Sélectionnez une habilitation FranceConnect qui sera liée à cette demande" est rempli