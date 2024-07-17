# Ajout d'un nouveau formulaire

Cette documentation est à destination des non-techniques souhaitant ajouter un
nouveau formulaire à un type d'habilitation existante.

Seul les sections 1. et 2. sont nécessaires pour obtenir un formulaire
fonctionnel. Le reste est optionnel (mais fortement conseillé).

## 1. Configuration du modèle

Il faut ajouter dans le bon fichier situé dans le [dossier de
configuration](../config/authorization_request_forms/) la configuration du
nouveau formulaire (pour API Entreprise le bon fichier est
[celui-ci](../config/authorization_request_forms/api_entreprise.yml))

La spécification détaillée de toutes les clés est situé [ici](./new_provider.md#configuration-du-authorizationrequestform).

* Si votre formulaire est lié à un cas d'usage, il faut ajouter la clé
  correspondante ;
* Si votre formulaire est lié à un éditeur, il faut ajouter la clé
  correspondante ainsi que le fournisseur.

Ces 2 points sont documentés dans le document ci-dessus.

## 2. Configuration de la vue

Il y a 2 cas :

1. Un formulaire sur une page ;
2. Un formulaire par étapes.

Le cas 2. est simple, il suffit d'ajouter les bonnes étapes dans le
configuration ci-dessus.

Pour le cas 1., il y a plusieurs cas de figure :

1. Si vous voulez copier un formulaire existant, il vous suffit de remplir le `single_page_view`
   avec la valeur du formulaire que vous voulez copier ;
2. Si vous voulez faire un nouveau formulaire, suivez la documentation
   [ici](./new_provider.md##42-cas-du-formulaire-sur-une-page) (peut nécessiter
   un développeur)

## 3. Personnalisation des textes

Les attributs d'une habilitation ont forcément des textes pré-définies à minima
pour l'ensemble des habilitations, et peuvent être aussi personnaliser pour le
type d'habilitation (ex: pour API Entreprise, l'attribute volumétrie possède un
`hint` personnalisé dont la valeur est `Nombre de démarches ou dossiers traités dans l'année`)

Se référer à [la documentation](./new_provider.md#3-configurer-les-formulations-via-li18n)

## 4. Ajout du test d'intégration

Le test permet de s'assurer programmatiquement que le formulaire est
fonctionnel.

Se référer à [la documentation](./new_provider.md#5-ajout-du-test-dint%C3%A9gration-cucumber)
