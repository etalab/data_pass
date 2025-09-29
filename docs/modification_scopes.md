# Modifications (ajout, retrait, dépréciation) de scopes

## Définition

Pour ajouter ou modifier un scope à un type d'habilitation, il faut modifier la
clé `scopes` du modèle correspondant dans le fichier [authorization\_definition
s.yml](../config/authorization_definitions.yml). Le format :


```yaml
scopes:
    # Nom affiché
  - name: Bilans des entreprises
    # Valeur technique, doit être unique
    value: bilans_des_entreprises
```

#### Scopes dépréciés avec l'option `deprecated`

Le système de gestion des scopes permet d'identifier et de gérer des scopes qui sont dépréciés mais encore
fonctionnels pour une période donnée. Cette fonctionnalité utilise l'objet `deprecated` dans le fichier de
configuration YAML.

#### Configuration

Les scopes dépréciés sont définis dans le fichier `config/authorization_definitions/dgfip.yml` avec la structure
suivante :

```yaml
scopes:
  # Nom affiché
  - name: Bilans des entreprises
    # Valeur technique, doit être unique
    value: bilans_des_entreprises
    # Configuration de dépréciation
    deprecated:
      # Date de début de la dépréciation au format ISO 8601 (obligatoire)
      since: 2023-10-01
      # Indique si le scope reste modifiable dans les demandes existantes (optionnel, défaut: true)
      writable: false
```

#### Options de l'objet `deprecated`

L'objet `deprecated` accepte deux propriétés :

- **`since`** (obligatoire) : Date de début de la dépréciation au format ISO 8601 (YYYY-MM-DD)
- **`writable`** (optionnel, défaut : `true`) : Booléen indiquant si le scope peut encore être coché/décoché dans les demandes d'habilitation existantes :
  - `true` : Le scope déprécié reste modifiable par les utilisateurs
  - `false` : Le scope déprécié devient en lecture seule (désactivé)

#### Comportement

Lorsqu'un scope est marqué comme déprécié :

1. Un avertissement est affiché aux utilisateurs pour les demandes et habilitations utilisant un scope qui est marqué
   comme déprécié
2. Il sera progressivement retiré des interfaces utilisateur

Le détail de l'ensemble des clés possibles se trouve [ici](new_provider.md#configuration-du-authorizationdefinition)

## Formulaires

Les formulaires servent à pré-remplir au démarrage d'une demande d'habilitation
des informations. Il est possible d'ajouter des scopes.

Le format:

```yaml
data:
  scopes:
    - bilans_des_entreprises
    - infos_des_entreprises
```

Il est aussi possible d'afficher/masquer des scopes sur les formulaires, tous
les détails sont [ici](https://github.com/etalab/data_pass/blob/develop/docs/new_provider.md#configuration-du-authorizationrequestform)

A noter que l'ajout ou le retrait d'un scope dans un formulaire ne changera pas
les demandes d'habilitations existantes, et qu'il faut pour cela effectuer des
migrations.
