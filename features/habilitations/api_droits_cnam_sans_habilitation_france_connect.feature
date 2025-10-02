# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API de droits à l'Assurance Maladie
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je ne peux pas démarrer de demande si je n'ai pas d'habilitation FranceConnect
    Quand je veux remplir une demande pour "API de droits à l'Assurance Maladie"
    Alors la page contient "Vous ne possédez pas d'habilitation à FranceConnect"
    Et la page ne contient pas "Demande libre"
