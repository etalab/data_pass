# language: fr

Fonctionnalité: Consultation des contacts supplémentaires sur les APIs DGFiP
  Les contacts supplémentaires saisis sur les formulaires DGFiP sont visibles à la consultation
  de la demande, quelle que soit l’API DGFiP concernée.

  Scénario: Je consulte une demande FICOBA avec des contacts supplémentaires
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que j'ai 1 demande d'habilitation "API Fichier des Comptes Bancaires et Assimilés (FICOBA)" à l'étape "Bac à sable" en attente
    Et que cette demande renseigne des contacts supplémentaires DGFiP
    Quand je me rends sur la dernière demande
    Alors il y a "generique@banque.fr" dans le bloc de résumé "Les personnes impliquées"
    Et il y a "Jean Secours" dans le bloc de résumé "Les personnes impliquées"
    Et il y a "secours@banque.fr" dans le bloc de résumé "Les personnes impliquées"

  Scénario: Un instructeur consulte une demande FICOBA avec des contacts supplémentaires
    Sachant que je suis un instructeur "API Fichier des Comptes Bancaires et Assimilés (FICOBA)"
    Et que je me connecte
    Et qu'il y a 1 demande d'habilitation "API Fichier des Comptes Bancaires et Assimilés (FICOBA)" via le formulaire "Demande libre (Production)" à l'étape "Production" en attente
    Et que cette demande renseigne des contacts supplémentaires DGFiP
    Quand je me rends sur la dernière demande à instruire
    Alors la page contient "generique@banque.fr"
    Et la page contient "Jean Secours"
    Et la page contient "secours@banque.fr"

  Scénario: Je consulte une habilitation FICOBA avec des contacts supplémentaires
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que j'ai 1 habilitation "API Fichier des Comptes Bancaires et Assimilés (FICOBA)" active à l'étape "Bac à sable"
    Et que cette demande renseigne des contacts supplémentaires DGFiP
    Quand je visite la page de mon habilitation
    Alors la page contient "generique@banque.fr"
    Et la page contient "Jean Secours"
    Et la page contient "secours@banque.fr"

  Scénario: Je consulte une demande API Impôt Particulier avec des contacts supplémentaires
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" en attente
    Et que cette demande renseigne des contacts supplémentaires DGFiP
    Quand je me rends sur la dernière demande
    Alors il y a "generique@banque.fr" dans le bloc de résumé "Les personnes impliquées"
    Et il y a "Jean Secours" dans le bloc de résumé "Les personnes impliquées"

  Scénario: Une demande hors DGFiP n’affiche pas de contact supplémentaire
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur une demande d'habilitation "API Entreprise" en attente
    Alors il n'y a pas "Contact supplémentaire" dans le bloc de résumé "Les personnes impliquées"
