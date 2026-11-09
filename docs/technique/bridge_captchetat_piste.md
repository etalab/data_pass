# Bridge CaptchEtat → PISTE

## PISTE, c’est quoi

[PISTE](https://piste.gouv.fr) (Plateforme d’Intermédiation des Services pour la Transformation de l’État)
est le portail d’API de l’AIFE (Agence pour l’informatique financière de l’État). C’est par lui que
l’AIFE distribue l’API CaptchEtat : un usager n’appelle CaptchEtat qu’avec une **application PISTE**
abonnée à l’API.

DataPass instruit les demandes d’accès à CaptchEtat (formulaire `api_captchetat`, fournisseur `aife`).
Une fois la demande validée, il faut que PISTE crée l’application de l’usager et l’abonne à l’API :
c’est le rôle du bridge.

## Ce que fait le bridge

À la validation d’une demande CaptchEtat, `ExecuteAuthorizationRequestBridge` met en file
`APICaptchEtatBridge` (`app/bridges/api_captchetat_bridge.rb`). Le job :

1. obtient un jeton auprès de PISTE (OAuth `client_credentials`) ;
2. appelle `POST /datapass/v1/approve` avec :

   ```json
   { "requestor_email": "<email du contact technique>", "approval_id": <id de la dernière habilitation>, "api_name": "CaptchEtat v2" }
   ```

3. lit `piste_app_prd_link` dans la réponse et en garde l’UUID final dans
   `AuthorizationRequest#external_provider_id`.

Côté PISTE, l’appel crée si besoin le compte de l’usager et l’application de production, puis l’abonne à
l’API. Le client HTTP est `PISTEAPIClient` (`app/services/piste_api_client.rb`).

Le bridge **informe** PISTE d’une validation déjà prononcée, comme un webhook : un échec n’annule pas
la validation dans DataPass.

## Contraintes côté PISTE

- **L’appel n’est pas idempotent.** Rejouer un `approval_id` déjà traité crée un doublon chez PISTE.
- **Un timeout ou un 5xx ne dit pas si l’application a été créée.** Elle l’est parfois malgré l’erreur.
- **Quota.** PISTE limite le nombre d’appels `/approve` de DataPass sur une fenêtre glissante. Au-delà,
  il répond 429, sans corps ni en-tête `Retry-After`.

D’où la politique de tentatives :

| Erreur | Comportement |
| -- | -- |
| 429, connexion impossible | jusqu’à 3 tentatives, espacées de 6 h |
| timeout, 5xx, 4xx, réponse sans `piste_app_prd_link` | abandon immédiat, pas de nouvel essai |

Chaque échec remonte aussitôt dans Sentry (tag `bridge: APICaptchEtatBridge`, avec la demande,
l’événement, le statut et le corps HTTP). Après un abandon, seul PISTE peut dire si l’application existe :
voir avec eux avant tout rejeu.

## Configuration

| Valeur | Source |
| -- | -- |
| `piste_oauth_url`, `piste_create_subscription_url`, `piste_client_id`, `piste_client_secret` | credentials |
| nom de l’API envoyé à PISTE (`api_name`) | `Setting` `piste_api_name`, défaut `CaptchEtat v2` |

PISTE a déjà renommé l’API (2024) et annonce le passage à `CaptchEtat v3`. Le changement se fait en
console, sans déploiement, à la date convenue avec PISTE (voir [Paramétrage en base](./parametrage_en_base.md)) :

```ruby
Setting.set(:piste_api_name, 'CaptchEtat v3')
```

## Rattraper une demande

Quand le bridge a abandonné, demander à PISTE (support : `piste.aife@finances.gouv.fr`) le lien de
l’application créée pour l’`approval_id` concerné, puis renseigner l’UUID en console :

```ruby
AuthorizationRequest.find(<id>).update_column(:external_provider_id, '<uuid>')
```

Si PISTE n’a rien créé, rejouer le bridge une seule fois :

```ruby
APICaptchEtatBridge.perform_later(AuthorizationRequest.find(<id>), :approve)
```
