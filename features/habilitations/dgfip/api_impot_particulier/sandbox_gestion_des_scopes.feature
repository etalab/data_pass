# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Impôts Particuliers bac à sable et verification de la compatibilité des règles de scopes
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

    Quand je démarre une nouvelle demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je choisis "Via le numéro fiscal (SPI)"
    * je clique sur "Suivant"

  @javascript
  Scénario: Je soumets une demande d'habilitation sans scopes mais je joins un fichier d'expression de besoin spécifique.
    * je coche "Oui, j’ai une expression de besoin spécifique"
    * je remplis "Ajoutez le fichier d’expression de vos besoins" avec le fichier "spec/fixtures/dummy.xlsx"
    * je clique sur "Suivant"

    Alors la page contient "Les personnes impliquées"


