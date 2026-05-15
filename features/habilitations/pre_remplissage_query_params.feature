# language: fr

Fonctionnalité: Pré-remplissage des champs d'une demande d'habilitation via les query params

  Un lien direct vers un formulaire accepte des query params nommés comme les
  attributs de la demande, qui sont pré-remplis dans le formulaire.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le champ intitulé est pré-rempli depuis un query param
    Quand je visite le formulaire "api-indicateurs-sociaux" avec le paramètre "intitule" égal à "Mon projet pré-rempli"
    Et que je clique sur "Débuter ma demande"

    Alors le champ "Nom du projet" contient "Mon projet pré-rempli"

  Scénario: Un champ d'une étape ultérieure est pré-rempli après soumission de l'étape précédente
    Quand je visite le formulaire "api-indicateurs-sociaux" avec le paramètre "cadre_juridique_url" égal à "https://legifrance.gouv.fr/preremplie"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    Alors le champ "URL du texte relatif au traitement" contient "https://legifrance.gouv.fr/preremplie"
