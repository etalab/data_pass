# Métadonnées des demandes

Une demande (`AuthorizationRequest`) porte une colonne `metadata` (jsonb), rangée par **espace de noms** :

```json
{
  "api":      { "campagne": "migration-editeur-x", "source": "api" },
  "datapass": { "lot": "reprise-octobre" }
}
```

| Espace | Écrit par | Exposé |
| --- | --- | --- |
| `api` | les fournisseurs de données, via `demande.metadata` de l'API v1 (`POST` / `PATCH /api/v1/demandes`) | réponses de l'API v1 (`metadata`) et charge utile des webhooks (`data.metadata`), à plat, sans le nom de l'espace |
| `datapass` | l'équipe DataPass, depuis la console (aucune interface pour l'instant) | nulle part |

Seul l'espace `api` sort de DataPass : les serializers de l'API et des webhooks lisent `metadata_for(:api)`. Le cloisonnement par fournisseur découle du type de la demande : l'API ne montre une demande qu'aux applications dont le propriétaire est développeur sur son type, et les webhooks sont rattachés à une définition. Les métadonnées ne figurent ni dans `data`, ni dans l'historique, ni dans les vues : le demandeur ne les voit pas. Un `PATCH` qui ne change que les métadonnées ne crée ni changelog ni événement `update_by_api` (`skip_empty_changelog` dans `UpdateAuthorizationRequestFromAPI`) : l'historique du demandeur n'affiche pas de mise à jour vide.

## Limites (par espace)

Définies par les validations ActiveModel de `AuthorizationRequestMetadata` (le contenu d'un espace) et de `AuthorizationRequestMetadata::Entry` (chaque couple clé / valeur), vérifiées à chaque sauvegarde du modèle :

- 20 clés au maximum ;
- clés de 40 caractères au maximum, format `[a-zA-Z0-9_.-]` ;
- valeurs texte, nombre ou booléen, sans objet, tableau ni `null` ;
- texte de 500 caractères au maximum.

La règle « aucune donnée personnelle » est documentée pour les fournisseurs (spec OpenAPI, tutoriel d'écriture) mais n'est pas contrôlée automatiquement. Pour un audit :

```ruby
AuthorizationRequest.where.not(metadata: {}).pluck(:id, :metadata)
```

## Depuis la console

```ruby
authorization_request.metadata_for(:datapass)                       # => {} si absent
authorization_request.assign_metadata(:datapass, { lot: 'reprise' }) # remplace l'espace, sans toucher aux autres
authorization_request.assign_metadata(:datapass, nil)               # retire l'espace
authorization_request.save!
```

## Ajouter un espace

1. L'ajouter à `AuthorizationRequestMetadata::NAMESPACES`.
2. Écrire avec `assign_metadata(:<espace>, …)` depuis le point d'entrée voulu.
3. Ne l'exposer à un fournisseur qu'après décision explicite : une donnée exposée ne peut plus être retirée sans casser les consommateurs.
