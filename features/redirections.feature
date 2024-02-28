# language: fr

Fonctionnalité: Démarrage d'habilitation par des internautes

  Scénario:  Un internaute veut remplir une demande d'habilitation API Entreprise via le formulaire "Demande Libre"
    Sachant que je suis un demandeur
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Demande libre"
    Alors il y a un titre contenant "Bienvenue sur DataPass !"
    Et la page contient "Vous souhaitez accédez à l’API Entreprise"
    Et la page contient "Votre demande d’habilitation va se dérouler en 4 étapes"
    Et la page contient "S’identifier avec MonComptePro"


  Scénario:  Un internaute veut remplir une demande d'habilitation API Entreprise via le formulaire "Marchés publics"
    Sachant que je suis un demandeur
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Marchés publics"
    Alors il y a un titre contenant "Bienvenue sur DataPass !"
    Et la page contient "Vous souhaitez accédez à l’API Entreprise"
    Et la page contient "Votre demande d’habilitation va se dérouler en 4 étapes"
    Et la page contient "S’identifier avec MonComptePro"

  Scénario:  Un internaute veut remplir une demande d'habilitation API Infinoe sandbox
    Sachant que je suis un demandeur
    Quand je veux remplir une demande pour "API Infinoe Sandbox" via le formulaire ""
    Alors il y a un titre contenant "Bienvenue sur DataPass !"
    Et la page contient "Vous souhaitez accédez à l’API INFINOE (Bac à sable)"
    Et la page contient "Votre demande d’habilitation va se dérouler en 4 étapes"
    Et la page contient "S’identifier avec MonComptePro"


  Scénario:  Un internaute veut demarer une demande d'habilitation API Entreprise via le formulaire "Demande Libre"
    Sachant que je suis un demandeur
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Demande libre"
    Alors je clique sur "S’identifier avec MonComptePro"
    Alors je suis sur la page "Démarrer une nouvelle habilitation pour API Entreprise"
    Et la page contient "demandeur@gouv.fr"
