# language: fr

@javascript
Fonctionnalité: Choix de la modalité d'appel et du stage du formulaire API Impôt Particulier

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je veux remplir une demande pour "API Impôt Particulier"

  Scénario: J'ai déjà un éditeur qui a accès au bac à sable
    Et que je choisis "Via l'état civil"
    Et que je choisis "Oui mon éditeur a déjà accès au bac à sable"
    Et que je clique sur "Démarrer ma demande d'habilitation en production"
    Alors la page contient "API Impôt Particulier avec éditeur"
  
  Scénario: Je n'ai pas encore accès au bac à sable
    Et que je choisis "Via l'état civil"
    Et que je choisis "Non, nous n'avons pas encore accès au bac à sable"
    Et que je clique sur "Démarrer ma demande d'habilitation en bac à sable"
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
    Et que je sélectionne "Habilitation du " pour "Sélectionnez une habilitation FranceConnect"
    Et que je choisis "Oui mon éditeur a déjà accès au bac à sable"
    Et que je clique sur "Démarrer ma demande d'habilitation en production"
    Alors la page contient "API Impôt Particulier avec éditeur"
