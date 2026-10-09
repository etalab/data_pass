# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation Services et applications fournis par le CISIRH
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation valide
    * je démarre une nouvelle demande d'habilitation "Services et applications fournis par le CISIRH"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je coche "Gestion administrative (GA)"
    * je clique sur "Suivant"

    Alors le bloc de contact "RSSI" est affiché
    Et la page contient "Responsable de la sécurité des systèmes d’information de votre organisation."
    Et aucun bloc de contact "Contact technique" n'est affiché

    * je renseigne les informations des contacts RGPD
    * je remplis les informations du contact "RSSI" avec :
      | Nom    | Prénom | Email               | Téléphone  | Fonction |
      | Dupont | Marc   | dupont.marc@gouv.fr | 0136656565 | RSSI     |
    * je clique sur "Suivant"

    Alors le bloc de contact "RSSI" est affiché
    Et aucun bloc de contact "Contact technique" n'est affiché

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Quand je me rends sur la dernière demande
    Alors le bloc de contact "RSSI" est affiché
    Et aucun bloc de contact "Contact technique" n'est affiché

  Scénario: Je ne renseigne pas le RSSI
    * je démarre une nouvelle demande d'habilitation "Services et applications fournis par le CISIRH"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je coche "Gestion administrative (GA)"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je clique sur "Suivant"

    Alors la page contient "Email du RSSI"
    Et la page ne contient pas "contact technique"

  Scénario: Je consulte une habilitation CISIRH validée
    Quand je me rends sur une demande d'habilitation "Services et applications fournis par le CISIRH" validée
    Et que je me rends sur l'habilitation validée
    Alors le bloc de contact "RSSI" est affiché
    Et aucun bloc de contact "Contact technique" n'est affiché

  Scénario: Un instructeur consulte une demande CISIRH soumise
    Sachant que je suis un instructeur "Services et applications fournis par le CISIRH"
    Quand je me rends sur une demande d'habilitation "Services et applications fournis par le CISIRH" soumise
    Alors la page contient "Les informations renseignées par le demandeur"
    Et le bloc de contact "RSSI" est affiché
    Et aucun bloc de contact "Contact technique" n'est affiché
