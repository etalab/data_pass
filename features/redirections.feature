# language: fr

Fonctionnalité: Démarrage d'habilitation par des internautes

  Scénario:  Un internaute veut remplir une demande d'habilitation API Entreprise via le formulaire "Demande Libre"
    Sachant que je suis un demandeur
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Demande libre"
    Alors il y a un titre contenant "Bienvenue sur DataPass !"
    Et la page contient "Vous souhaitez accédez à l’API Entreprise"
    Et la page contient "Votre demande d’habilitation va se dérouler en 4 étapes"
    Et la page contient "S’identifier avec ProConnect"

  Scénario:  Un internaute veut remplir une demande d'habilitation API Entreprise via le formulaire "Marchés publics"
    Sachant que je suis un demandeur
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Marchés publics"
    Alors il y a un titre contenant "Bienvenue sur DataPass !"
    Et la page contient "Vous souhaitez accédez à l’API Entreprise"
    Et la page contient "Votre demande d’habilitation va se dérouler en 4 étapes"
    Et la page contient "S’identifier avec ProConnect"

  Scénario:  Un internaute veut démarrer une demande d'habilitation API Entreprise via le formulaire "Demande Libre"
    Sachant que je suis un demandeur
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Demande libre"
    Alors je clique sur "S’identifier avec ProConnect"
    Alors je suis sur la page "Demander une habilitation à : API Entreprise"
    Et la page contient "DUPONT Jean"

  Scénario:  Un internaute veut accéder à son habilitation API scolarité de l'élève - formulaire "Demande libre"
    Sachant que je suis un demandeur
    Quand je me rends sur une demande d'habilitation "API scolarité de l'élève" validée
    Alors il y a un titre contenant "Bienvenue sur DataPass !"
    Alors la page contient le logo du fournisseur de données "API scolarité de l'élève"
    Alors je clique sur "S’identifier avec ProConnect"
    Alors il y a un formulaire en mode résumé

  Scénario: Un internaute veut démarrer une demande d'habilitation API Entreprise
    Sachant que je suis un demandeur
    Quand je veux remplir une demande pour "API Entreprise"
    Alors il y a un titre contenant "Bienvenue sur DataPass !"
    Alors la page contient le logo du fournisseur de données "API Entreprise"
    Alors je clique sur "S’identifier avec ProConnect"
    Et la page contient "Demander une habilitation à : API Entreprise"
