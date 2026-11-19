# language: fr

Fonctionnalité: Registre wallet, étape « Les contacts »
  Le demandeur indique qui contacter dans son organisation : le responsable de l’application,
  le contact technique et le délégué à la protection des données (DPP-210). Ces contacts ne
  sont pas publiés.

  Contexte:
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je remplis l’étape « L’organisation » du registre wallet
    Et je remplis l’étape « Le service » du registre wallet
    Et je remplis l’étape « Les utilisations prévues » du registre wallet

  Scénario: L’étape s’ouvre vide et dit que les contacts ne sont pas publiés (CA4)
    Alors la page contient "Étape 4/4"
    Et la page contient "Qui pouvons-nous contacter dans votre organisation ?"
    Et la page contient "Elles ne sont pas publiées : l’usager ne les voit pas."
    Et la page ne contient pas "contact registre"
    Et la page ne contient pas "suppression des données"
    Et le bouton « C’est moi » est proposé dans les contacts "Responsable de l’application, Contact technique, Délégué à la protection des données (DPO)"

  Scénario: Les trois contacts remplis sont dans le brouillon et au récapitulatif (CA1)
    Quand je remplis l’étape « Les contacts » du registre wallet
    Alors le brouillon du registre wallet a pour contact technique "Jules Lefèvre"
    Et la page contient "Les contacts de l’organisation"
    Et la page contient "Ces contacts ne sont pas publiés."
    Et la page contient "dpo@clamart.fr"

  Scénario: Une étape vide garde le demandeur sur l’étape (CA3)
    Quand je clique sur "Suivant"
    Alors la page contient "12 points à corriger avant de continuer"
    Et la page contient "Indiquez le nom du responsable de l’application."
    Et la page contient "Indiquez le téléphone du délégué à la protection des données."

  Scénario: Le bandeau de l’étape ne liste que ses erreurs, même si les étapes précédentes sont incomplètes (RG8)
    Sachant que les étapes 1 à 3 de mon brouillon du registre wallet ont été vidées
    Quand je recharge la page
    Et je clique sur "Suivant"
    Alors la page contient "12 points à corriger avant de continuer"
    Et la page contient "Indiquez le nom du responsable de l’application."
    Et la page ne contient pas "Indiquez l’adresse de votre politique de confidentialité"
    Et la page ne contient pas "Indiquez le nom du service."
    Et la page ne contient pas "Ajoutez au moins une utilisation prévue."

  Plan du scénario: Un format refusé garde le demandeur sur l’étape (CA3)
    Quand je remplis les trois contacts du registre wallet
    Et je remplis le champ "<champ>" du contact "Contact technique" avec "<valeur>"
    Et je clique sur "Suivant"
    Alors la page contient "Un point à corriger avant de continuer"
    Et la page contient "<bandeau>"
    Et la page contient "<message>"

    Exemples:
      | champ                | valeur          | bandeau                                         | message                                                            |
      | adresse électronique | jules.lefevre@  | Contact technique : adresse électronique non valide | Indiquez une adresse électronique valide, par exemple nom@domaine.fr |
      | téléphone            | 04 72           | Contact technique : numéro de téléphone non valide  | Indiquez un numéro de téléphone valide, par exemple 04 72 00 00 00   |
      | nom                  | ---             | Indiquez le nom du contact technique.               | Indiquez le nom du contact technique.                              |

  Scénario: Une saisie incomplète reste dans le brouillon et « Précédent » reste possible (RG8)
    Quand je remplis le champ "nom" du contact "Contact technique" avec "Lefèvre"
    Et je clique sur "Enregistrer"
    Alors le brouillon du registre wallet a pour contact technique " Lefèvre"
    Quand je clique sur "Précédent"
    Alors la page contient "Étape 3/4"

  Scénario: Le bouton « C’est moi » n’est proposé que dans le contact où le demandeur s’est désigné (RG7)
    Quand je saisis à la main mes nom, prénom et adresse électronique dans le contact "Contact technique"
    Et je clique sur "Enregistrer"
    Alors le bouton « C’est moi » est proposé dans le contact "Contact technique"

  @javascript
  Scénario: « C’est moi » remplit le contact technique et disparaît des deux autres (CA2, CA7)
    Quand je clique sur « C’est moi » dans le contact "Contact technique"
    Alors le contact "Contact technique" porte mes nom, prénom et adresse électronique, sans téléphone
    Et le bouton « C’est moi » est proposé dans le contact "Contact technique"
    Quand je vide le contact "Contact technique"
    Alors le bouton « C’est moi » est proposé dans les contacts "Responsable de l’application, Contact technique, Délégué à la protection des données (DPO)"

  @javascript
  Scénario: « C’est moi » sur une étape en erreur retire l’erreur des champs qu’il remplit
    Quand je clique sur "Suivant"
    Et je clique sur « C’est moi » dans le contact "Contact technique"
    Alors les champs "nom, prénom, adresse électronique" du contact "Contact technique" ne sont plus signalés en erreur
    Et le champ "téléphone" du contact "Contact technique" est signalé en erreur
    Et le champ "nom" du contact "Responsable de l’application" est signalé en erreur

  @javascript
  Scénario: Le format du téléphone est contrôlé en quittant le champ (RG8)
    Quand je remplis le champ "téléphone" du contact "Contact technique" avec "04 72"
    Et je quitte le champ "authorization_request_registre_wallet_wallet_technical_contact_phone_number"
    Alors la page contient "Indiquez un numéro de téléphone valide, par exemple 04 72 00 00 00"
