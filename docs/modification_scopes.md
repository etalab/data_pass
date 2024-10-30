# Modifications (ajout, retrait) de scopes

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
