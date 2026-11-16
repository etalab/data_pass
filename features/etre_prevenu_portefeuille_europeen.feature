# language: fr

Fonctionnalité: Être prévenu de l’ouverture du registre du portefeuille européen
  En tant que visiteur non connecté,
  je laisse mon adresse et mon profil pour être prévenu de l’ouverture du registre
  et du parcours qui me concerne.

  Scénario: Un visiteur s’inscrit avec son profil
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Et je choisis "Un intermédiaire ou un éditeur de logiciel"
    Et je remplis "Votre adresse électronique" avec "Jean.Dupont@example.com"
    Et je clique sur "M’inscrire"
    Alors il y a un message de succès contenant "Votre inscription est enregistrée"
    Et l’adresse "jean.dupont@example.com" est inscrite une seule fois avec le profil « intermediary »

  Scénario: Une adresse déjà inscrite met à jour son profil, sans doublon
    Sachant que l’adresse "jean.dupont@example.com" est inscrite avec le profil « organization »
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Et je choisis "Un fournisseur d’attestations"
    Et je remplis "Votre adresse électronique" avec "jean.dupont@example.com"
    Et je clique sur "M’inscrire"
    Alors il y a un message de succès contenant "Votre inscription est enregistrée"
    Et l’adresse "jean.dupont@example.com" est inscrite une seule fois avec le profil « attestation_provider »

  Scénario: Une adresse invalide affiche une erreur sous le champ et n’enregistre rien
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Et je choisis "Un intermédiaire ou un éditeur de logiciel"
    Et je remplis "Votre adresse électronique" avec "jean.dupont"
    Et je clique sur "M’inscrire"
    Alors le champ « Votre adresse électronique » est en erreur avec « Saisissez une adresse électronique valide, au format nom@example.com. »
    Et la page ne contient pas "Votre inscription est enregistrée"
    Et aucune adresse n’est inscrite

  Scénario: Sans profil choisi, le choix « Vous êtes » est en erreur et rien n’est enregistré
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Et je remplis "Votre adresse électronique" avec "jean.dupont@example.com"
    Et je clique sur "M’inscrire"
    Alors le choix « Vous êtes » est en erreur avec « Choisissez ce qui vous décrit. »
    Et la page ne contient pas "Votre inscription est enregistrée"
    Et aucune adresse n’est inscrite

  Scénario: Un robot qui remplit le champ piège voit une confirmation, mais rien n’est enregistré
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Et je choisis "Un intermédiaire ou un éditeur de logiciel"
    Et je remplis "Votre adresse électronique" avec "robot@example.com"
    Et je remplis le champ piège du bloc « Être prévenu »
    Et je clique sur "M’inscrire"
    Alors il y a un message de succès contenant "Votre inscription est enregistrée"
    Et aucune adresse n’est inscrite

  Scénario: Au-delà de 10 envois en une minute, l’inscription n’aboutit pas
    Sachant que 10 inscriptions ont été envoyées depuis ma connexion dans la minute
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Et je choisis "Un intermédiaire ou un éditeur de logiciel"
    Et je remplis "Votre adresse électronique" avec "jean.dupont@example.com"
    Et je clique sur "M’inscrire"
    Alors il y a un message d'erreur contenant "Nous avons reçu trop d’inscriptions depuis votre connexion"
    Et l’adresse "jean.dupont@example.com" n’est pas inscrite

  @registre_ouvert
  Scénario: Une fois le registre ouvert, seuls les intermédiaires et les fournisseurs d’attestations s’inscrivent
    Sachant que le registre du portefeuille européen est ouvert
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Et je choisis "Un fournisseur d’attestations"
    Et je remplis "Votre adresse électronique" avec "jean.dupont@example.com"
    Et je clique sur "M’inscrire"
    Alors il y a un message de succès contenant "Votre inscription est enregistrée"
    Et l’adresse "jean.dupont@example.com" est inscrite une seule fois avec le profil « attestation_provider »

  @javascript
  Scénario: Avec JavaScript, l’erreur s’affiche dans le bloc et le focus va sur le champ en erreur
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Et je choisis "Un intermédiaire ou un éditeur de logiciel"
    Et je remplis "Votre adresse électronique" avec "jean.dupont"
    Et je clique sur "M’inscrire"
    Alors le champ « Votre adresse électronique » est en erreur avec « Saisissez une adresse électronique valide, au format nom@example.com. »
    Et le focus est sur le champ « Votre adresse électronique »
    Quand je remplis "Votre adresse électronique" avec "jean.dupont@example.com"
    Et je clique sur "M’inscrire"
    Alors il y a un message de succès contenant "Votre inscription est enregistrée"
    Et le focus est sur la confirmation d’inscription

  Scénario: Le bloc renvoie vers la description du traitement dans la politique de confidentialité
    Quand je me rends sur le chemin "/portefeuille-europeen"
    Alors la page contient un lien "En savoir plus sur la gestion de vos données" vers "/politique-confidentialite#etre-prevenu-portefeuille-europeen"
    Quand je me rends sur le chemin "/politique-confidentialite"
    Alors la page contient "Prévenir la personne inscrite de l’ouverture du registre des parties utilisatrices du portefeuille européen"
    Et la page contient un lien "https://www.cnil.fr/fr/adresser-une-plainte" vers "https://www.cnil.fr/fr/adresser-une-plainte"
