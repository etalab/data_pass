# Glossaire DataPass

Vocabulaire de référence pour les textes de DataPass : mails, écrans, documentation.
Il ne renomme rien dans le code ni dans l’API : les noms techniques sont donnés pour faire le lien.

> Statut : rédigé pour DPP-43, en relecture par la PO.

## La règle de base

**Une demande aboutit à une habilitation.** Pour chaque texte, on se demande quel objet est en jeu :
la demande (le dossier) ou l’habilitation (le droit obtenu). Le texte nomme cet objet.

## Les deux objets

### Demande

Dossier déposé par un demandeur pour obtenir l’accès à des données, du brouillon jusqu’à la
décision de l’instructeur. Numéro : **D…** (ex. D123).

- Statuts affichés : Brouillon, En cours d’instruction, Modifications demandées, Validée, Refusée,
  Supprimée.
- Une demande est refusée, validée, supprimée, transférée.
- On dit : « Votre demande D123 a été refusée. »
- On évite : « Votre habilitation a été refusée. »
- Quand le texte désigne **une** demande précise (par son numéro ou son nom), on écrit « votre
  demande D123 » ou « la demande « nom » ». « Demande d’habilitation » reste pour l’action générique :
  « Démarrer ma demande d’habilitation », « une nouvelle demande d’habilitation pour l’API … ».
- Nom technique : `AuthorizationRequest`.

### Habilitation

Droit d’accès aux données, obtenu quand un instructeur valide une demande. Numéro : **H…**
(ex. H456).

- Statuts affichés : Active, Révoquée, Obsolète (remplacée par une habilitation plus récente).
- Une habilitation est délivrée, révoquée, mise à jour.
- Une même demande peut donner lieu à plusieurs habilitations successives : une par étape (bac à
  sable, production), et une nouvelle à chaque mise à jour validée.
- On dit : « Votre demande D123 a été validée : elle a donné lieu à l’habilitation H456. »
- On évite : « habilitation validée », « habilitation refusée », « Votre habilitation numéro D123 ».
- Nom technique : `Authorization`.

## Les actions

### Valider une demande, délivrer une habilitation

L’instructeur valide la demande ; cette validation délivre l’habilitation. Une demande validée *est*
une habilitation : on parle donc de l’habilitation délivrée, pas de la demande validée.

« Demande validée » ne s’écrit que par exception :

- le statut « Validée » sur la page d’une demande, que les instructeurs peuvent encore consulter ;
- le mail DGFiP APIM, qui nomme aussi l’habilitation (« la demande D… a été validée, elle a donné
  lieu à l’habilitation H… ») ;
- la valeur technique `validated` de l’API.

### Refuser, révoquer

- On **refuse une demande** : aucune habilitation n’est délivrée.
- On **révoque une habilitation** : elle cesse d’être valide. Sa demande passe aussi au statut
  « Révoquée ».

### Demander des modifications

Action de l’instructeur qui renvoie la demande au demandeur sans la valider. La demande passe au
statut « Modifications demandées ».

On n’emploie pas « demande de modification » comme nom : « demande » désigne déjà le dossier.

### Mettre à jour une habilitation

Le demandeur modifie une habilitation active (contacts, documents, données…) : il clique sur
« Mettre à jour l’habilitation », ce qui ouvre une **demande de mise à jour** sur la même demande.
L’habilitation en cours reste valide pendant cette instruction ; si la demande de mise à jour est
validée, une nouvelle habilitation remplace l’ancienne.

« Réouverture » reste le nom technique du cycle (`reopening`) et n’apparaît plus dans les textes.

### Transférer

Changer le demandeur rattaché à une demande. On parle de **demande** tant qu’aucune habilitation n’a
été délivrée, d’**habilitation** ensuite, avec le numéro correspondant.

## Ce à quoi on demande l’accès

### Formulaire

Ce à quoi on demande l’accès : API Entreprise, API Particulier, FranceConnect… Remplace « type
d’habilitation » et « type de demande ».

Noms techniques : `AuthorizationDefinition` (formulaires décrits dans le code) et `HabilitationType`
(formulaires créés depuis l’administration).

### Cas d’usage

Variante d’un formulaire adaptée à un usage précis, souvent pré-remplie : « Demande libre »,
« Marchés publics », le logiciel d’un éditeur… Un formulaire propose un ou plusieurs cas d’usage, dont
un cas d’usage par défaut.

Le mot « formulaire » garde son sens courant quand il désigne la page à remplir (« remplissez le
formulaire ci-dessous »).

Noms techniques : `AuthorizationRequestForm` (dans le code) et `FormTemplate` (depuis
l’administration).

### Étapes : bac à sable, production

Certains formulaires se font en deux étapes : un accès de test (bac à sable, données fictives), puis
un accès aux données réelles (production). Chaque étape délivre sa propre habilitation.

## Les personnes

- **Demandeur** : la personne qui dépose la demande, pour le compte de son organisation.
- **Instructeur** : la personne qui, pour le fournisseur de données, valide, refuse ou demande des
  modifications sur une demande, et peut révoquer une habilitation.
- **Fournisseur de données** : l’administration qui ouvre l’accès à ses données (DGFiP, DINUM…).
