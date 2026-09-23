# language: fr

Fonctionnalité: Adresse IP publique et adresse postale du contact technique sur les APIs DGFiP prioritaires
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: L'adresse IP publique est obligatoire dès l'étape du projet
    Quand je veux remplir une demande pour "API Fichier des Comptes Bancaires et Assimilés (FICOBA)" via le formulaire "Demande libre (Bac à sable)" à l'étape "Bac à sable"
    * je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je remplis "Adresse IP publique de connexion" avec ""
    * je clique sur "Suivant"

    Alors il y a un message d'erreur contenant "Adresse IP publique de connexion"

  Scénario: Une adresse IP privée est refusée
    Quand je veux remplir une demande pour "API Fichier des Comptes Bancaires et Assimilés (FICOBA)" via le formulaire "Demande libre (Bac à sable)" à l'étape "Bac à sable"
    * je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je remplis "Adresse IP publique de connexion" avec "192.168.1.1"
    * je clique sur "Suivant"

    Alors il y a un message d'erreur contenant "doit être une adresse IP publique"

  Scénario: L'adresse du contact technique est obligatoire, son complément non
    Quand je veux remplir une demande pour "API Fichier des Comptes Bancaires et Assimilés (FICOBA)" via le formulaire "Demande libre (Bac à sable)" à l'étape "Bac à sable"
    * je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je coche "Via le Numéro fiscal (SPI)"
    * je clique sur "Suivant"

    * je coche "État civil/Raison sociale du titulaire du compte"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je remplis "Adresse du contact technique" avec ""
    * je clique sur "Suivant"

    Alors il y a un message d'erreur contenant "Adresse du contact technique"

  Scénario: Je soumets une demande complète, les deux champs sont conservés
    Quand je veux remplir une demande pour "API Fichier des Comptes Bancaires et Assimilés (FICOBA)" via le formulaire "Demande libre (Bac à sable)" à l'étape "Bac à sable"
    * je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je coche "Via le Numéro fiscal (SPI)"
    * je clique sur "Suivant"

    * je coche "État civil/Raison sociale du titulaire du compte"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je coche "J’atteste que mon organisation devra déclarer à la DGFiP l’accomplissement des formalités en matière de protection des données à caractère personnel et qu’elle veillera à procéder à l’homologation de sécurité de son projet."
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"

    Quand je clique sur le premier "Consulter"
    Alors il y a "192.0.2.10" dans le bloc de résumé "Mon projet"
    Et il y a "10 rue de la Paix, 75002 Paris" dans le bloc de résumé "Les personnes impliquées"

  Scénario: Du bac à sable à la production, les deux champs traversent tout le parcours
    Quand je veux remplir une demande pour "API Fichier des Comptes Bancaires et Assimilés (FICOBA)" via le formulaire "Demande libre (Bac à sable)" à l'étape "Bac à sable"
    * je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je coche "Via le Numéro fiscal (SPI)"
    * je clique sur "Suivant"

    * je coche "État civil/Raison sociale du titulaire du compte"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je coche "J’atteste que mon organisation devra déclarer à la DGFiP l’accomplissement des formalités en matière de protection des données à caractère personnel et qu’elle veillera à procéder à l’homologation de sécurité de son projet."
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"

    Et un instructeur a validé la demande d'habilitation
    Et que je me rends sur mon tableau de bord habilitations

    Quand je clique sur "Démarrer ma demande d’habilitation en production"
    Et que je clique sur "Débuter ma demande"

    Alors la page ne contient pas le champ "Adresse IP publique de connexion"
    Et la page ne contient pas le champ "Adresse du contact technique"

    * je renseigne la recette fonctionnelle
    * je clique sur "Suivant"

    * je renseigne l'homologation de sécurité
    * je clique sur "Suivant"

    * je renseigne la volumétrie
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je coche "J’atteste que mon organisation devra déclarer à la DGFiP l’accomplissement des formalités en matière de protection des données à caractère personnel et qu’elle veillera à procéder à l’homologation de sécurité de son projet."
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"

    Quand je clique sur le premier "Consulter"
    Alors la page contient "192.0.2.10"
    Et la page contient "10 rue de la Paix, 75002 Paris"

  Scénario: Une API DGFiP hors périmètre n'affiche aucun des deux champs
    Quand je veux remplir une demande pour "API OPALE" via le formulaire "API OPALE" à l'étape "Bac à sable"
    * je clique sur "Débuter ma demande"

    Alors la page ne contient pas le champ "Adresse IP publique de connexion"

  @javascript
  Scénario: Une demande à modifier créée avant l'ajout des deux champs peut être complétée bloc par bloc puis re-soumise
    Quand j'ai 1 demande d'habilitation "API Fichier des Comptes Bancaires et Assimilés (FICOBA)" à l'étape "Bac à sable" en attente de modification
    Et que cette demande n'a ni adresse IP publique ni adresse du contact technique
    Et que je me rends sur cette demande d'habilitation

    Quand je clique sur "Modifier" dans le bloc de résumé "Mon projet"
    Et que je remplis "Adresse IP publique de connexion" avec "192.0.2.10"
    Et que je clique sur "Enregistrer les modifications"
    Alors il y a "192.0.2.10" dans le bloc de résumé "Mon projet"

    Quand je clique sur "Modifier" dans le bloc de résumé "Les personnes impliquées"
    Et que je remplis "Adresse du contact technique" avec "10 rue de la Paix, 75002 Paris"
    Et que je clique sur "Enregistrer les modifications"
    Alors il y a "10 rue de la Paix, 75002 Paris" dans le bloc de résumé "Les personnes impliquées"

    Quand je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message de succès contenant "soumise avec succès"

  @javascript
  Scénario: Une demande à modifier créée avant l'ajout des deux champs ne peut pas être re-soumise tant qu'il en manque un
    Quand j'ai 1 demande d'habilitation "API Fichier des Comptes Bancaires et Assimilés (FICOBA)" à l'étape "Bac à sable" en attente de modification
    Et que cette demande n'a ni adresse IP publique ni adresse du contact technique
    Et que je me rends sur cette demande d'habilitation

    Quand je clique sur "Modifier" dans le bloc de résumé "Mon projet"
    Et que je remplis "Adresse IP publique de connexion" avec "192.0.2.10"
    Et que je clique sur "Enregistrer les modifications"
    Et que je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message d'erreur contenant "Adresse du contact technique"
