# Droits API par fournisseur de données

La soumission et la validation de demandes par l’API sont deux droits distincts, accordés à une application OAuth par un administrateur DataPass, fournisseur de données (FD) par FD, avec un historique complet (qui, quand, pourquoi).

## Double contrôle

1. **Doorkeeper (scope du jeton).** Le jeton doit porter `submit_authorizations` ou `validate_authorizations`, déclarés comme scopes optionnels dans `config/initializers/doorkeeper.rb`.
2. **`APIAccessPolicy` (contrôle en direct).** La policy vérifie que le propriétaire de l’application a le rôle développeur sur le type d’habilitation et qu’un `APIAccessGrant` actif existe pour l’application, l’action et le FD du type.

Les deux niveaux existent parce qu’un jeton `client_credentials` vit 2 heures : le scope porté par le jeton ne reflète pas l’état courant des droits. Le contrôle en direct garantit qu’une révocation coupe l’accès immédiatement, même avec un jeton qui porte encore le scope. Inversement, un jeton émis avant un octroi ne porte pas le nouveau scope : l’application doit demander un nouveau jeton.

## Utiliser la policy dans un contrôleur

```ruby
doorkeeper_authorize! :submit_authorizations
authorize definition, :submit?, policy_class: APIAccessPolicy
```

`definition` est la définition d’habilitation visée. Pour la validation, utiliser `:validate_authorizations` et `:validate?`. Le `pundit_user` de l’API est un `APIUserContext` (utilisateur propriétaire plus application Doorkeeper).

## Validation par API

`POST /api/v1/demandes/:id/valider` (`API::V1::AuthorizationRequestsController#validate`) applique `APIAccessPolicy#validate?` puis appelle `ApproveAuthorizationRequestFromAPI`. Cet organizer vérifie que `instructeur.email` désigne un instructeur du type, puis que la demande est `submitted` et approuvable par cet instructeur selon `Instruction::AuthorizationRequestPolicy#approve?` (la même règle que dans l’interface, restreinte par l’API aux demandes `submitted`), puis délègue à `ApproveAuthorizationRequest` avec cet instructeur comme `user` : les effets sont donc ceux de la validation dans l’interface.

L’origine par API est portée par `authorization_request_events.api_application_name` (nom recopié, sans clé étrangère), alimenté par `context.api_application_name`. L’événement garde le nom `approve` : aucun événement `approve_by_api` n’est émis, pour ne pas modifier les abonnements webhook. `HistoricalAuthorizationRequestEventComponent` affiche la clé `message_summary_by_api` quand le nom d’application est présent.

## Soumission par API

`POST /api/v1/demandes/:id/soumettre` (`API::V1::AuthorizationRequestsController#submit`) applique `APIAccessPolicy#submit?` puis appelle `SubmitAuthorizationRequestFromAPI`. Cet organizer vérifie que la demande est soumettable (`can_submit?`), que chaque case de `AuthorizationRequest#required_consents` est transmise à `true` dans `consentement` (`EnsureConsentsGiven`), puis délègue à `SubmitAuthorizationRequest` avec le **demandeur** comme `user` : l’API ne soumet jamais au nom du fournisseur de données et les effets sont ceux de la soumission dans l’interface.

Une case déjà cochée sur le brouillon ne vaut pas consentement : le fournisseur de données doit la déclarer à chaque soumission. `required_consents` alimente aussi le champ `consentements` des définitions ; pour une définition, la liste est calculée sur une instance vierge, donc les cases conditionnelles (ex. l’alternative FranceConnect, qui dépend de la modalité) n’y figurent que si la demande les exige, et l’erreur « Consentement manquant » donne la liste exacte.

Les erreurs par champ sont construites par `APIErrorsFacade` : `/data/<champ>` à partir des erreurs du modèle (`authorization_request_invalid`), `/consentement/<case>` pour `consent_missing`. Elles sont produites pour tout échec `authorization_request_invalid` dont la demande porte des erreurs de modèle ; une erreur de base (par exemple les conditions non acceptées) n’a pas de `source.pointer`.

L’origine par API est portée par `authorization_request_events.api_application_name`, comme pour la validation. L’événement garde le nom `submit` ; `HistoricalAuthorizationRequestEventComponent` affiche la variante `message_summary_by_api` de chaque formulation de soumission (le nom affiché dépend du journal des modifications, d’où sept variantes).

## Réponses 403 et changement de comportement

`API::V1Controller` rend toujours un `403` au format `errors[]` avec le titre « Droit API manquant » (textes dans `config/locales/api_errors.fr.yml`) :

- scope manquant (`Doorkeeper::Errors::TokenForbidden`) : message générique, qui ne cite aucun FD et invite à demander un nouveau jeton ;
- droit manquant (`Pundit::NotAuthorizedError` sur `APIAccessPolicy`) : message explicite « soumettre » ou « valider » ;
- tout autre refus Pundit dans l’API : message générique, jamais une 500.

**Changement de comportement.** Avant ce changement, un scope manquant était traité par le gestionnaire générique des erreurs Doorkeeper et renvoyait un `422`. Il renvoie maintenant un `403` sur **tous** les endpoints à scope, y compris les existants (`write_authorizations`, `read_webhooks`, etc.). Les tutoriels et la spec OpenAPI ont été alignés.

## Octroi, révocation et synchronisation des scopes

`Admin::GrantAPIAccess` et `Admin::RevokeAPIAccess` créent ou révoquent le droit puis alignent `Doorkeeper::Application#scopes` sur les droits actifs (`Admin::SyncAPIAccessScopes`), le tout dans une seule transaction. Les droits sont **par FD** ; les types d’habilitation utilisables restent limités par les rôles développeur du propriétaire (à confirmer avec le PO, le ticket parlant de « fournisseur et type d’habilitation »). Un droit n’est accordé que si le propriétaire couvre au moins un type du FD. `write_authorizations` n’est pas concerné et reste inchangé.

## Suppression d’une application

`RevokesAPIAccessOnDestroy` (inclus dans `Doorkeeper::Application`) révoque les droits actifs avant la suppression, avec la raison « Application supprimée » et le marqueur `revoked_automatically` (sans e-mail de révocateur).

## Historique

Les droits révoqués sont conservés. Le nom de l’application et les e-mails de l’octroyeur et du révocateur humain sont dénormalisés sur la ligne : l’historique survit à la suppression d’une application ou d’un utilisateur. Les droits d’un fournisseur supprimé sont supprimés avec lui (la suppression n’est possible que pour un fournisseur sans type d’habilitation ni définition) ; les scopes de l’application sont alors resynchronisés.

## Écran d’administration

`/admin/acces-api` liste les droits, permet d’en accorder un et de le révoquer avec un motif obligatoire. L’écran est réservé aux administrateurs et utilise `true_user` pour l’acteur tracé ; l’accès est contrôlé par `AdminController` sur `true_user`, y compris pendant une impersonation.

## Noms des scopes

Les noms vivent à un seul endroit : `config/initializers/api_scopes.rb` (`APIScopes::BY_ACTION`), lu par la config Doorkeeper et par le modèle. Ils sont provisoires jusqu’à DPP-141. Pour les renommer :

1. modifier `APIScopes::BY_ACTION` ;
2. ajouter une migration de données qui renomme l’ancien scope dans `oauth_applications.scopes` (voir `ScopeMigrationService`) ;
3. mettre à jour `config/openapi/v1.yaml` et `docs/developers/tutorials/ecriture.md`.

Une application sans scopes explicites (colonne vide) obtient, à l’émission du jeton, tous les scopes du serveur Doorkeeper (et non les seuls scopes par défaut) : la synchronisation part alors de cet ensemble, retire les scopes de droits API puis ajoute ceux des droits actifs, et les écrit explicitement pour que l’application ne perde ni `write_authorizations` ni `read_webhooks`.

La synchronisation supprime les scopes qui ne sont plus déclarés dans Doorkeeper : un scope obsolète présent sur l’application disparaît à la prochaine synchronisation, au lieu de faire échouer la mise à jour.

## Options de contrat par FD

`data_providers.api_contract_options` est une colonne `jsonb` (défaut `{}`), vide pour l’instant. Le contrat est unique par FD (« un contrat par FD ») ; DPP-148 la remplira, clés par type d’e-mail.

## Limites connues

- Le statut « Actif » signifie « non révoqué ». Un droit reste actif mais inutilisable si le propriétaire perd le rôle développeur, car la policy revérifie les rôles à chaque appel.
- `oauth_application_id` n’a pas de clé étrangère : le callback `before_destroy` est la seule protection. `delete`, `delete_all` ou du SQL brut sur `oauth_applications` contournent la révocation automatique et sont à éviter.
- La liste d’administration n’a pas de filtres.
- Les données de démonstration (développement et sandbox) créent deux applications :
  - « API Entreprise » (propriétaire `dev-apie@yopmail.com`) avec un droit de soumission et un droit de validation sur DINUM ;
  - « API Particulier et API Droits CNAM » (propriétaire `dev-multi-fd@yopmail.com`, développeur sur deux fournisseurs) avec un droit de soumission actif sur DINUM, un droit de validation retiré sur la CNAM, et les autres droits à accorder depuis `/admin/acces-api`.
