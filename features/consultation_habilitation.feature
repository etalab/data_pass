# language: fr

Fonctionnalité: Consultation d'une habilitation
  Description des différents scénario de consultation en fonction de l'état de l'habilitation,
  du type de formulaire et de la relation entre l'utilisateur courant et l'habilitation
  cible: demandeur, appartenant à l'organisation ou mentionné.

  Seules les habilitations appartenant à l'utilisateur courant possède des actions de modifications.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je consulte une habilitation active m'appartenant
    Quand j'ai 1 habilitation "API Entreprise" active
    Et je visite la page de mon habilitation
    Alors il n'y a pas de bouton "Sauvegarder"
    Alors il y a un bouton "Mettre à jour"
    Alors il y a un bouton "Transférer"
    Et il y a un formulaire en mode résumé non modifiable

  Scénario: Je consulte un habilitation revoked m'appartenant
    Quand j'ai 1 habilitation "API Entreprise" révoquée
    Et je visite la page de mon habilitation
    Alors il n'y a pas de bouton "Sauvegarder"
    Alors il y a un bouton "Contacter le support"
    Et il y a un formulaire en mode résumé non modifiable

  Scénario: Je consulte une habilitation API Impôt Particulier bac à sable active m'appartenant
    Quand j'ai 1 habilitation "API Impôt Particulier" active à l'étape "Bac à sable"
    Et je visite la page de mon habilitation
    Alors il y a un badge "Bac à sable"
    Et il y a un badge "Active"

  Scénario: Je consulte une habilitation API Impôt Particulier production obsolète m'appartenant
    Quand j'ai 1 habilitation "API Impôt Particulier" obsolète à l'étape "Production"
    Et je visite la page de mon habilitation
    Alors il y a un badge "Production"
    Et il y a un badge "Obsolète"

#TODO: Faire le test pour une habilitation en multi stage
  @pending
  Scénario: Je consulte une habilitation Impot particulier Bas à sable active m'appartenant
    Quand j'ai 1 habilitation "API Hermes" active à l'étape "Bac à sable"
    Et je visite la page de mon habilitation
    Alors il y a un bouton "Démarrer ma demande d’habilitation de production"
    Et il y a un formulaire en mode résumé non modifiable

#TODO : Faire le test dans le cas ou on a une habilitation Obsolète
  @pending
  Scénario: Je consulte une habilitation obsolète m'appartenant
    Quand j'ai 1 habilitation "API Entreprise" obsolete
    Et je visite la page de mon habilitation
    Alors il y a un bouton "Contacter le support"
    Et il y a un formulaire en mode résumé non modifiable

  Scénario: Je consulte une habilitation obsolète lié à une demande d'habilitation ayant une habilitation plus récente modifiée
    Quand j'ai une habilitation "API Entreprise" liée à une demande d'habilitation ayant une habilitation obsolete ayant des données différentes
    Et je visite la page de mon habilitation
    Alors la page contient "old_scope"
    Et la page ne contient pas "new_scope"


