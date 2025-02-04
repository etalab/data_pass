# language: fr

Fonctionnalité: Demandes d'habilitation ayant des configurations sur les scopes
  Ces scénarios traduisent les diverses propriétés existantes sur les scopes des demandes
  d'habilitation, tel que le caractère désactivé des cases à cochées, ou encore de l'affichage
  de ces scopes. Le tout est déterminé au niveau du formulaire (ou du contexte de la demande)
  et non au niveau de la définition.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je consulte la page des scopes d'une demande d'habilitation où il n'y a pas d'options sur les scopes, où tous les scopes sont affichés
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Demande libre"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
    * je clique sur "Suivant"

    Alors la page contient "Les données"
    Et la page contient "API Quotient familial"
    Et la page contient "API Statut étudiant boursier"
    Et la page contient "API Prime d'Activité"

  Scénario: Je consulte la page des scopes d'une demande d'habilitation où il y a des options de désactivation et d'affichage

    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Domino web 2.0" de l'éditeur "Abelium Collectivités"
    Et que je clique sur "Débuter ma demande"

    Alors la page contient "Les données"
    Et la page contient "API Quotient familial"
    Et la page ne contient pas "API Statut étudiant boursier"
    Et je ne peux pas cocher "Quotient familial CAF & MSA"
    Et je peux cocher "Identités allocataire et conjoint"
