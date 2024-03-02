# language: fr

Fonctionnalité: Instruction: modification des préférences de notifications par email
  Un instructeur peut modifier ses préférences de notification par emails vis-à-vis
  des demandes associées à son périmètre d'instruction.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je suis un instructeur "API Particulier"
    Et que je me connecte
    Et que je vais sur la page de mon compte

  Scénario: Je vois les préférences de notifications par email activées par défaut
    Alors l'interrupteur "Notifications pour les dépôts de demandes d'habilitations" dans le bloc de paramètres "API Entreprise" est activé
    Et l'interrupteur "Notifications pour les dépôts de demandes d'habilitations" dans le bloc de paramètres "API Particulier" est activé
    Et la page ne contient pas "API INFINOE"

  @javascript
  Scénario: Je change une préférence de notification pour les soumissions
    Quand je clique sur l'interrupteur "Notifications pour les dépôts de demandes d'habilitations" dans le bloc de paramètres "API Entreprise"
    Et que je vais sur la page de mon compte
    Alors l'interrupteur "Notifications pour les dépôts de demandes d'habilitations" dans le bloc de paramètres "API Entreprise" est désactivé
