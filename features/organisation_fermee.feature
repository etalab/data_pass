# language: fr

Fonctionnalité: Restriction sur les organisations fermées
  Les organisations fermées ne peuvent pas effectuer certaines actions sur les demandes car celles-ci
  ne sont plus des entités valides

  Contexte:
    Sachant que je suis un demandeur d'une organisation fermée
    Et que je me connecte

  Scénario: Je ne peux pas démarrer une nouvelle demande pour le compte d'une organisation fermée
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise"
    Alors la page contient "Désolé, vous ne pouvez pas faire de nouvelle demande"
    Et la page ne contient pas "Démarrer"
