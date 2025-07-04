# language: fr

@javascript
Fonctionnalité: Choix de la modalité d'appel et du stage du formulaire API Impôt Particulier

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je veux remplir une demande pour "API Impôt Particulier"

  Scénario: Je veux accèder à l'API via l'état civil
    Alors la page contient "Cliquez-ici pour faire une demande"

  Scénario: J’ai déjà un éditeur qui a accès au bac à sable
    Et que je choisis "Via le numéro fiscal (SPI)"
    Et que je choisis "Oui, j’ai un éditeur qui a finalisé et validé ses développements en bac à sable"
    Et que je clique sur "Demande libre avec éditeur"
    Alors la page contient "Demande libre avec éditeur"

  Scénario: Je n’ai pas encore accès au bac à sable
    Et que je choisis "Via le numéro fiscal (SPI)"
    Et que je choisis "Non, nous n’avons pas d’éditeur qui a finalisé et validé ses développements en bac à sable"
    Et que je clique sur "Demande libre (Bac à sable)"
    Alors la page contient "Le bac à sable"

  Scénario: Je veux accéder à l’API via FranceConnect alors que je n’ai pas d'habilitation FranceConnect
    Et que je choisis "Avec FranceConnect"
    Alors la page contient "il vous faudra au préalable demander une habilitation FranceConnect"
    Et la page ne contient pas "Sélectionnez une habilitation FranceConnect"
    Et la page ne contient pas "Demande libre"

  Scénario: Je veux accéder à l’API via FranceConnect et j’ai déjà une habilitation FranceConnect
    Sachant que mon organisation a 1 demande d'habilitation "FranceConnect" validée
    Et que je rafraîchis la page
    Et que je choisis "Avec FranceConnect"
    Alors le champ "Sélectionnez une habilitation FranceConnect qui sera liée à cette demande" est rempli
    Quand je choisis "Oui, j’ai un éditeur qui a finalisé et validé ses développements en bac à sable"
    Et que je clique sur "Demande libre avec éditeur"
    Alors la page contient "Demande libre avec éditeur"

  Scénario: Je veux accéder à l’API via le numéro fiscal (SPI), et mon choix est retenu une fois arrivé au bloc de modalités d’accès
    * je choisis "Via le numéro fiscal (SPI)"
    * je choisis "Oui, j’ai un éditeur qui a finalisé et validé ses développements en bac à sable"
    * je clique sur "Demande libre avec éditeur"
    * je clique sur "Débuter ma demande"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"
    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"
    * je renseigne le cadre légal
    * je clique sur "Suivant"
    Alors "Via le numéro fiscal (SPI)" est coché

  Scénario: Je veux accéder à l’API via FranceConnect, et mon choix est retenu une fois arrivé au bloc de modalités d’accès
    Sachant que mon organisation a 1 demande d'habilitation "FranceConnect" validée
    * je rafraîchis la page
    * je choisis "Avec FranceConnect"
    * je choisis "Oui, j’ai un éditeur qui a finalisé et validé ses développements en bac à sable"
    * je clique sur "Demande libre"
    * je clique sur "Débuter ma demande"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"
    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"
    * je renseigne le cadre légal
    * je clique sur "Suivant"
    Alors "Avec FranceConnect" est coché
    Et le champ "Sélectionnez une habilitation FranceConnect qui sera liée à cette demande" est rempli
