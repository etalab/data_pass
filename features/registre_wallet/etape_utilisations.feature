# language: fr

Fonctionnalité: Registre wallet, étape « Les utilisations prévues »
  Pour chaque utilisation prévue, le demandeur déclare la finalité et les données que son
  service demandera au wallet (DPP-209), parmi les attestations du référentiel (DPP-205).

  Contexte:
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je remplis l’étape « L’organisation » du registre wallet
    Et je remplis l’étape « Le service » du registre wallet

  Scénario: L’étape s’ouvre sans utilisation, avec le compteur de certificats
    Alors la page contient "Étape 3/3"
    Et la page contient "Pourquoi demandez-vous des données aux usagers ?"
    Et la page contient "Aucune utilisation prévue pour l’instant"
    Et la page contient "Vous recevrez un certificat d’enregistrement par utilisation prévue, soit 0"
    Et la page ne contient pas "évalu"

  Scénario: Une utilisation avec trois données du PID donne des Credential TS5 (CA1)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute l’attestation "Données d’identification personnelle (PID)" à la dernière utilisation
    Et je coche les données "Nom, Prénoms, Date de naissance" de la dernière utilisation
    Et je clique sur "Suivant"
    Alors la page ne contient pas "à corriger avant de continuer"
    Et la page contient "Les utilisations prévues des données"
    Et la page contient "Vérifier la majorité"
    Et la page contient "Date de naissance"
    Et la page contient "1 certificat d’enregistrement"
    Et le brouillon du registre wallet produit "urn:eudi:pid:1" au format Credential

  Scénario: Deux utilisations donnent deux certificats et un choix d’aperçu (CA2, CA9)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute une utilisation prévue "Ouvrir un compte client"
    Alors la page contient "soit 2"
    Et la page contient "Utilisation prévue affichée"

  @javascript
  Scénario: L’aperçu montre la deuxième utilisation dès qu’elle est ajoutée (CA9)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute une utilisation prévue "Ouvrir un compte client"
    Et je remplis le champ "Pourquoi demandez-vous ces données ?" de la dernière utilisation avec "Créer votre compte client et le contrat à votre nom."
    Alors l’aperçu montre l’utilisation "Ouvrir un compte client" et "Créer votre compte client et le contrat à votre nom."
    Quand je choisis "Vérifier la majorité" comme utilisation affichée
    Alors l’aperçu montre l’utilisation "Vérifier la majorité" et "Vérifier que vous avez plus de 18 ans avant de vous louer un vélo."

  Scénario: Sans utilisation, l’aperçu invite à en ajouter une (CA9)
    Alors la page contient "Ce que verra l’usager"
    Et la page contient "Ajoutez une utilisation prévue pour voir l’aperçu."

  Scénario: Une seule utilisation n’affiche pas le choix d’aperçu (CA9)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Alors la page contient "Ce que verra l’usager"
    Et la page ne contient pas "Utilisation prévue affichée"

  Scénario: Sans utilisation, le demandeur reste sur l’étape (CA3)
    Quand je clique sur "Suivant"
    Alors la page contient "Un point à corriger avant de continuer"
    Et la page contient "Ajoutez au moins une utilisation prévue."

  Scénario: Une utilisation sans donnée ni finalité garde le demandeur sur l’étape (CA3)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et je remplis le champ "Pourquoi demandez-vous ces données ?" de la dernière utilisation avec ""
    Et je clique sur "Suivant"
    Alors la page contient "2 points à corriger avant de continuer"
    Et la page contient "Vérifier la majorité : indiquez la finalité."
    Et la page contient "Vérifier la majorité : ajoutez une attestation."

  Scénario: Une attestation sans donnée cochée est signalée (CA3, RG10)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute l’attestation "Permis de conduire mobile" à la dernière utilisation
    Et je clique sur "Suivant"
    Alors la page contient "Vérifier la majorité : cochez au moins une donnée dans « Permis de conduire mobile »."
    Et la page contient "Cochez au moins une donnée dans cette attestation, ou retirez-la."

  Plan du scénario: Une finalité « <finalité> » est refusée (CA4)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute l’attestation "Permis de conduire mobile" à la dernière utilisation
    Et je coche les données "Plus de 18 ans" de la dernière utilisation
    Et je remplis le champ "Pourquoi demandez-vous ces données ?" de la dernière utilisation avec "<finalité>"
    Et je clique sur "Suivant"
    Alors la page contient "Un point à corriger avant de continuer"
    Et la page contient "Vérifier la majorité : la finalité est trop courte."
    Et la page contient "Expliquez à l’usager pourquoi vous demandez ces données, en 15 caractères au moins"

    Exemples:
      | finalité |
      | ---      |
      | ok       |

  Scénario: Une politique changée pour une utilisation ne change pas les autres (CA5)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute une utilisation prévue "Ouvrir un compte client"
    Et je remplis le champ "Politique de confidentialité de cette utilisation" de la première utilisation avec "https://www.clamart.fr/majorite"
    Et je clique sur "Enregistrer"
    Alors les politiques de confidentialité des utilisations sont "https://www.clamart.fr/majorite, https://www.clamart.fr/confidentialite"

  Scénario: Une date de début passée garde le demandeur sur l’étape (CA6)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute l’attestation "Permis de conduire mobile" à la dernière utilisation
    Et je coche les données "Plus de 18 ans" de la dernière utilisation
    Et je remplis le champ "Date de début" de la dernière utilisation avec "2020-01-01"
    Et je clique sur "Suivant"
    Alors la page contient "Vérifier la majorité : la date de début est passée."
    Et la page contient "La date de début ne peut pas être passée : indiquez aujourd’hui ou une date à venir."

  Scénario: Une date de fin avant la date de début garde le demandeur sur l’étape (CA6)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute l’attestation "Permis de conduire mobile" à la dernière utilisation
    Et je coche les données "Plus de 18 ans" de la dernière utilisation
    Et je remplis le champ "Date de fin" de la dernière utilisation avec "2020-01-01"
    Et je clique sur "Suivant"
    Alors la page contient "Vérifier la majorité : la date de fin est avant la date de début."

  Scénario: Une utilisation n’est supprimée qu’après confirmation (CA10)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et je clique sur "Supprimer" dans la dernière utilisation
    Et je clique sur "Annuler" dans la dernière utilisation
    Alors le brouillon du registre wallet compte 1 utilisation prévue
    Quand je confirme "Supprimer l’utilisation" dans la dernière utilisation
    Alors le brouillon du registre wallet compte 0 utilisation prévue
    Et la page contient "Aucune utilisation prévue pour l’instant"

  Scénario: Une attestation n’est retirée qu’après confirmation, sans bandeau (CA11)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute l’attestation "Permis de conduire mobile" à la dernière utilisation
    Et je coche les données "Plus de 18 ans" de la dernière utilisation
    Et je clique sur "Enregistrer"
    Alors la page contient "Retirer l’attestation « Permis de conduire mobile » ?"
    Et la page contient "La donnée cochée dans cette attestation sera aussi retirée de l’utilisation « Vérifier la majorité »."
    Quand je confirme "Retirer l’attestation" dans la dernière utilisation
    Alors la page contient "Aucune attestation pour cette utilisation."
    Et la page ne contient pas "a été supprimée"

  Scénario: Une attestation déjà ajoutée ne s’ajoute pas deux fois (RG6)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute l’attestation "Permis de conduire mobile" à la dernière utilisation
    Et j’ouvre le catalogue des attestations de la dernière utilisation
    Alors la page contient "Déjà ajoutée Permis de conduire mobile"

  Scénario: Sans JavaScript, le catalogue est une page qui cherche et revient à l’utilisation
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ouvre le catalogue des attestations de la dernière utilisation
    Alors la page contient "Ajouter une attestation"
    Et la page contient "2 attestations dans le catalogue de la Commission"
    Quand je cherche "IDENTITE" dans le catalogue des attestations
    Alors la page contient "1 attestation dans le catalogue de la Commission"
    Et la page contient "Données d’identification personnelle (PID)"
    Et la page ne contient pas "Permis de conduire mobile"
    Quand je cherche "iban" dans le catalogue des attestations
    Alors la page contient "Aucune attestation ne correspond à votre recherche."
    Quand je clique sur "Revenir à l’utilisation prévue"
    Alors la page contient "Vérifier la majorité"

  @javascript
  Scénario: La fenêtre du catalogue cherche sur le serveur
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ouvre le catalogue des attestations de la dernière utilisation
    Et je cherche "permis" dans le catalogue des attestations
    Alors la page contient "1 attestation dans le catalogue de la Commission"
    Et la page ne contient pas "Données d’identification personnelle (PID)"

  @javascript
  Scénario: La carte se replie et résume ses données ; Annuler garde l’utilisation (RG2, CA10)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute l’attestation "Permis de conduire mobile" à la dernière utilisation
    Et je coche les données "Plus de 18 ans" de la dernière utilisation
    Alors la page contient "Permis de conduire mobile · 1 donnée demandée"
    Quand je clique sur "Replier" dans la dernière utilisation
    Alors la page contient "Permis de conduire mobile : plus de 18 ans"
    Quand je clique sur "Supprimer" dans la dernière utilisation
    Alors la page contient "Supprimer l’utilisation prévue « Vérifier la majorité » ?"
    Quand je clique sur "Annuler" dans la dernière utilisation
    Alors la page ne contient pas "Supprimer l’utilisation prévue « Vérifier la majorité » ?"
    Et le brouillon du registre wallet compte 1 utilisation prévue

  @javascript
  Scénario: Les données d’une attestation ajoutée sont repliées, et l’erreur disparaît dès qu’on coche (CA3)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute l’attestation "Permis de conduire mobile" à la dernière utilisation
    Alors la page contient "Afficher les données"
    Et la page ne contient pas "Masquer les données"
    Quand je clique sur "Suivant"
    Alors la page contient "Cochez au moins une donnée dans cette attestation, ou retirez-la."
    Quand je coche les données "Plus de 18 ans" de la dernière utilisation
    Alors la page ne contient pas "Cochez au moins une donnée dans cette attestation, ou retirez-la."
    Et la page ne contient pas "cochez au moins une donnée dans « Permis de conduire mobile »"

  @javascript
  Scénario: La finalité est contrôlée dès que le demandeur quitte le champ (RG10)
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et je remplis le champ "Pourquoi demandez-vous ces données ?" de la dernière utilisation avec "ok"
    Et je quitte le champ "Pourquoi demandez-vous ces données ?"
    Alors la page contient "Expliquez à l’usager pourquoi vous demandez ces données, en 15 caractères au moins"
    Et la page contient "2/300 caractères"
