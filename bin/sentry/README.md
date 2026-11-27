# Outils Sentry

Scripts en lecture seule pour interroger l’API Sentry (`errors.data.gouv.fr`) depuis le dépôt, sans MCP :
utiles pour lire l’événement derrière une alerte (code HTTP, message, contexte) quand l’interface web
n’est pas à portée.

## Installation

1. Créer un token sur https://errors.data.gouv.fr/settings/account/api/auth-tokens/ avec les scopes
   `event:read` et `project:read`.
2. L’enregistrer à la racine du dépôt (le fichier est ignoré par git) :

```bash
echo "votre_token" > .sentry_token
```

Le token est cherché d’abord dans le dossier courant, puis à la racine du dépôt.

## Réglages

| Variable | Défaut |
| -- | -- |
| `SENTRY_URL` | `https://errors.data.gouv.fr` |
| `SENTRY_ORG` | `sentry` |
| `SENTRY_PROJECT` | `datapass-reborn` |

## Scripts

```bash
bin/sentry/issues                                      # issues non résolues, 14 jours
bin/sentry/issues -q "INSEE"                           # recherche libre
bin/sentry/issues -p 24h -q "is:unresolved level:error environment:staging"
bin/sentry/issue 312436                                # détail : exception, contexte, tags
```

L’API n’accepte que les périodes `24h` et `14d`.
