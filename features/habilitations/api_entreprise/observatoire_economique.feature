# language: fr

Fonctionnalité: Cas d’usage « Observatoire économique » d’API Entreprise
  Les acteurs publics qui suivent le tissu économique de leur territoire disposent
  d’un formulaire guidé dont les données sont fixées.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  @javascript
  Scénario: Le cas d’usage est proposé dans le catalogue et mène à sa page d’accueil
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise"
    Et que je choisis "Vos développeurs"
    Alors je vois 1 tuile "Observatoire économique"
    Et la page contient "Connaître, analyser et suivre le tissu économique d’un territoire."

  Scénario: La page d’accueil présente les objectifs et les 5 étapes
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Observatoire économique"
    Alors la page contient "Une agence d’urbanisme qui analyse le tissu entrepreneurial local"
    Et la page contient "Les données sont fixées pour ce cas d’usage : vous n’aurez pas à les choisir."
    Et les étapes annoncées du formulaire sont :
      | Mon projet                             |
      | Le cadre juridique                     |
      | Les données                            |
      | Le traitement des données personnelles |
      | Les personnes impliquées               |

  Scénario: Le parcours guide le demandeur avec des données fixées et des aides adaptées
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Observatoire économique"
    Et que je clique sur "Débuter ma demande"
    Alors la page contient "Nous avons pré-rempli des informations pour vous aider"
    Et le champ "Nom du projet" contient "Observatoire économique du territoire"
    Et le champ "Description du projet" contient "Connaître, analyser et suivre le tissu économique de notre territoire (entreprises et associations), à partir de données actualisées, pour éclairer nos politiques de développement économique."

    Quand je clique sur "Suivant"
    Alors le panneau d’aide "Comment trouver le cadre juridique ?" contient "article L132-6 du code de l’urbanisme"
    Et le panneau d’aide "Comment trouver le cadre juridique ?" contient "arrêté préfectoral"

    Quand je clique sur "Suivant"
    Alors il y a au moins une erreur sur un champ
    Et la page contient "Nature du cadre juridique doit être rempli"

    Quand je renseigne le cadre légal
    Et que je clique sur "Suivant"
    Alors la page contient "Les données sont fixées pour ce cas d’usage"
    Et la page ne contient pas "Comment choisir les données ?"
    Et le panneau d’aide "Où consulter la documentation des données ?" contient "catalogue des API"
    Et le lien "catalogue des API" s’ouvre dans une nouvelle fenêtre annoncée
    Et "Données unités légales et établissements du répertoire Sirene - Insee et extrait RNE - INPI (diffusibles et non-diffusibles) | 🔐" est coché et non modifiable
    Et "Effectifs - GIP-MDS | 🔐" est coché et non modifiable
    Et "Données des unités légales et établissements diffusibles - Insee | Open Data" est coché et non modifiable
    Et la page ne contient pas "Données associations - DJEPVA | 🔐"
    Et la page ne contient pas "Liasses fiscales - DGFIP"

    Quand je clique sur "Suivant"
    Alors le champ "Destinataire des données" a une indication contenant "entrepreneurs individuels"
    Et le champ "Destinataire des données" a une indication contenant "Plus d'infos"

  Scénario: Les autres cas d’usage gardent leurs aides habituelles
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Aides publiques"
    Et que je clique sur "Débuter ma demande"
    Et que je renseigne les infos de bases du projet
    Et que je clique sur "Suivant"
    Alors la page contient "Comment trouver le cadre juridique ?"
    Et la page ne contient pas "article L132-6 du code de l’urbanisme"
