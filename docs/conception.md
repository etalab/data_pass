# Conception métier/technique

Ce qui n'est pas actuellement implémenté est signifié avec l'accronyme `NYI`
(`Not Yet Implemented`)

## I. Couche modèle

L'ajout d'une nouvelle habilitation (partie 1., 2. et 3.) est documenté de
manière explicite dans le document [Ajout d'un nouveau fournisseur](./new_provider.md)

### 1. Définition d'habilitation

Cette définition permet de définir des attributs statiques d'une demande
d'habilitation, tel que le nom, description, liens vers les CGUs, fournisseur de
données.

Il s'agit de modèles stockés en dur dans le code, via des fichiers de
configuration.

### 2. Les demandes d'habilitations

Une demande d'habilitation est le contrat effectif entre une organisation et un
fournisseur de données. Celui-ci peut se remplir via différents formulaires.

Les définitions statiques sont tirées de 1.

Chaque demande possède un cycle de vie déterminer via une machine à états. Les
états sont les suivants:

1. `draft`: état initial, lorsque le demandeur démarre la demande d'habilitation ;
2. `submitted`: lorsque l'usager a soumis sa demande d'habilitation ;
3. `NYI` `changes_requested`: lorsqu'un instructeur demande des modifications au
   demandeur ;
4. `refused`: l'instructeur a refusé la demande d'habilitation. Il s'agit d'un
   état final pour la demande.
5. `validated`: l'instructeur a validé la demande d'habilitation

Chaque état influe sur les actions possibles sur une demande d'un point de vue
controller (via la stack d'autorisation).

Lors du démarrage d'une demande, en fonction du nombre de formulaires,
l'interface change afin d'aiguiller au maximum le demandeur.

On précise systématiquement pour quelle organisation l'habilitation va être
remplie, et une introduction de ce à quoi va consister le formulaire.

Si il y a plusieurs formulaires disponibles, par défaut il s'agit d'un simple
index sans aide, il est possible de personnaliser cette page (par exemple avec
un arbre de décision `NYI`)

### 3. Formulaires de demandes d'habilitation

Permet de remplir des habilitations. Certains formulaires peuvent pré-remplir
des informations directement à la création. Ces informations peuvent être
modifiées ou non, cela dépend de comment le formulaire est configuré.

Il y a 2 grands types de formulaires:

1. Sur une page: lorsqu'il n'y a pas énormément d'information à renseigné
2. En plusieurs étapes: lorsqu'il faut renseigner pas mal d'informations de la
   part du demandeur

Une habilitation peut posséder plusieurs formulaires, en fonction des cas
d'usages.

Par exemple pour API Entreprise:

1. Formulaire pour un cas d'usage précis avec un éditeur précis: on ne renseigne
   que les infos des contacts RGPD, tout le reste est pré-rempli (caché ou non).
2. Formulaire en demande libre: en plusieurs étapes, beaucoup plus technique et

Il s'agit de modèles stockés en dur dans le code, via des fichiers de
configuration.

### 4. Habilitation

`NIY` (not sure?) Formulaire validé et figé, associé à la demande.

### 5. Utilisateurs

Il y a 3 types d'utilisateur `User`, distingués via le tableau `roles`

1. Les usagers normaux: principalement les demandeurs, sans roles ;
2. Les instructeurs: instruisent les demandes (possède des rôles de type
   `mon_api:instructor`)
3. `NYI` Les rapporteurs
4. `NYI` Les administrateurs: peuvent changer les instructeurs (possède le rôle
   `administrator`)

### 5. Organisations

Il s'agit de l'entité principale, à laquelle les habilitations sont rattachées.

`NYI` Certaines informations de l'organisation peuvent être renseignées afin de
simplifier le remplissage. Par exemple le DPO ou DPD, à partir du moment que
celui-ci a été renseigné.

### 6. Fournisseurs de données

Définition des fournisseurs de données, associés aux définitions des
habilitations.

Il s'agit de modèles stockés en dur dans le code, via des fichiers de
configuration.

## II. Différences avec l'ancienne version

1. Le demandeur n'est plus réellement l'entité centrale, il s'agit
   maintenant de l'organisation, et pas mal d'informations seront tirés de la
   dite organisation: DPD, DPO ..

   Cela implique par ailleurs que l'usager est connecté en tant qu'agent de
   l'organisation, et qu'il ne voit pas ses demandes sur les autres
   organisations. Il peut cependant changer depuis son profil, ou lorsqu'il se
   connecte.

   Visuellement on affiche de manière explicite l'organisation courante dans
   l'entête principale

2. Les habilitations peuvent avoir plusieurs formulaires associés, en fonction
   de critères tel que les cas d'usages, les éditeurs..
3. Les habilitations sont beaucoup plus configurables et ne possède plus aucun
   attributs ou blocs communs (seul l'organisation et le demandeur sont des
   attrubuts communs).

   Il existe des blocs communs que l'on peut ajouter
   pour des éléments communs (infos de base du projet, contacts RGPD ...)
