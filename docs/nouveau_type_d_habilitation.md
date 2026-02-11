# Ajout d'un nouveau fournisseur

Il existe un générateur `definition`:

```sh
bundle exec rails g definition
```

---

La checklist globale:

1. Ajouter le ou les entrée(s) dans les fichiers de config ;
2. Ajouter et configurer le modèle (avec sa factory et son test) ;
3. Configurer les formulations via l'I18n ;
4. Ajouter la vue de complétion côté demandeur ;
5. Ajouter un test d'intégration Cucumber ;
6. Importer les données existantes.

Disclaimer : La procédure est amené à évoluer rapidement, et certaines parties seront
peut-être obsolètes. Il y a par ailleurs des refactorisations logiques, mais
potentiellement prématurés : il faut attendre d'intégrer plus de sources pour
être sûr d'effectuer les refactorisations nécessaires.

## 1. Fichiers de configurations (liés aux modèles finaux)

Une demande d'habilitation (le modèle) est lié à un ou plusieurs formulaires. Il
faut à minima en remplir un de chaque et qu'ils soient liés.

D'un point de vue de la couche modèle il y a :

1. `AuthorizationDefinition`, qui est un modèle statique, qui définie les
   attributs du type d'habilitation ;
2. `AuthorizationRequestForm`, qui est un modèle statique, qui définie les
   attributs d'un formulaire associé à un type d'habilitation ;
3. `AuthorizationRequest`, modèle en db, qui représente la demande effective
   associé à une association. Celle-ci référence la définition et le modèle
   associé au formulaire

#### Configuration du `AuthorizationDefinition`

Pour la configuration de la [définition (1.)](../config/authorization_definitions/):

```yaml
  # Il s'agit du nom de la classe en underscore. Ici `MonAPI`
  mon_api:
    # Nom affiché dans l'index des formulaires et en titre par défaut de chaque
    # formulaire exploitant cette habilitation
    name: Mon API
    # Description affichée dans l'index des habilitations.
    description: Une description
    # ID du provider (cf 1.1 plus bas)
    provider: dinum
    # Optionnel. Lien pour en savoir plus. Par défaut le lien du fournisseur est pris
    link: https://mon-api.gouv.fr
    # Lien vers les CGU
    cgu_link: https://mon-api.gouv.fr/cgu.pdf
    # Lien pour récupérer son accès. Ce lien peut interpoler la variable `external_provider_id`
    access_link:  https://mon-api.gouv.fr/compte/tokens/%{external_provider_id}
    # Email de support
    support_email: support@mon-api.gouv.fr
    # Type de service. Valeurs possibles : api, service.
    # Cette valeur sert principalement à personnaliser les textes, notamment sur la page de
    # démarrage d'une demande.
    kind: 'api'
    # Optionnel. Affiche ou non cette source de données dans l'index des formulaires. Par défaut à `true`
    public: true
    # Optionnel. Détermine s'il ne peut y avoir qu'un seul formulaire par organisation. Par défaut à `false`
    unique: false
    # Optionnel. Détermine si ce formulaire peut être démarré à l'initiative de
    # l'utilisateur. Cet attribut sert principalement aux habilitations en 2
    # étapes (bac à sable puis production), lorsque la 1ʳᵉ est validé la 2e est
    # crée par le système. Par défaut à `true`
    startable_by_applicant: true
    # Optionnel. Permet de désactiver des fonctionnalités pour ce type de
    # demande. Seules la messagerie (messaging), le transfert et la réouverture (reopening) sont supportés pour le moment
    features:
      messaging: true
      transfer: true
      reopening: true
    # Optionnel. Permet de définir des étapes (ex : sandbox -> production)
    stage:
      # Type: sandbox / production
      type: sandbox
      # Information concernant l'étape suivante, clé obligatoire si le type est sandbox
      next:
        id: api_impot_particulier
        form_id: api-impot-particulier
      # Information concernant l'étape précedente. Clé obligatoire si le
      # type est production. Cette information mimique le comportement
      # d'ActiveRecord qui implémente la réversibilité et permet ainsi de plus
      # simplement faire les liens entre les modèles. Pour plus d'infos
      # effectuer un `git blame` sur ces lignes
      previous:
        id: api_impot_particulier_sandbox
        form_id: api-impot-particulier-sandbox
    # Liste des diverses données débrayables pour la source de données
    scopes:
        # Nom humanisé de la donnée
      - name: Nom de famille
        # Nom technique de la donnée
        value: family_name
        # Nom du groupe pour cette donnée afin d'effectuer
        # un regroupement visuel
        group: Identité pivot
        # Optionnel. Lien vers des détails sur la donnée. Affiche un lien pour
        # en savoir plus sur cette donnée.
        link: https://mon-api.gouv.fr/documentation/nom-de-famille
        # Optionnel. Détermine si la donnée est forcément incluse. Cela permet
        # d'afficher des données grisées et cochés à l'utilisateur pour l'informer
        # que ces données seront disponibles avec son habilitation. Par défaut à
        # false. Il n'est donc pas nécessaire de spécifier le scope dans
        # l'option `scopes_config→disabled` du formulaire.
        included: true
        # Optionnel. Détermine si la donnée est désactivée. Cela permet
        # d'afficher des données grisées et non cochés à l'utilisateur, ceci permet
        # par exemple d'afficher des futures données disponibles ou plus disponibles.
        # Par défaut à false. Il n'est donc pas nécessaire de spécifier le scope dans
        # l'option `scopes_config→disabled` du formulaire.
        disabled: true
        # Optionnel. Permet de préciser les options de dépréciation de la donnée.
        deprecated:
          # Date de début de la dépréciation, obligatoire si l'option
          # est définie
          since: 2024-12-31
          # Optionnel. Détermine si la donnée est modifiable ou non. Par défaut
          # à false
          writable: false

    # Liste des blocs à afficher dans le résumé
    # Ces blocs peuvent correspondre aux 'steps' des formulaires définis
    # ci-dessous, mais ce n'est pas une obligation. Chaque bloc doit être défini
    # dans app/views/authorization_requests/shared/blocks/default/
    blocks:
      - name: basic_infos
      - name: legal
      - name: personal_data
      - name: scopes
      - name: contacts
```

#### Configuration du `AuthorizationRequestForm`

Pour la configuration d'un [formulaire (2.)](../config/authorization_request_forms/):

```yaml
  # Identifiant unique qui sera utilisé dans les URLs
  mon-api-form:
    # Nom affiché en titre du formulaire. Par défaut celui de l'habilitation est
    # prise
    name: Mon API dans le formulaire
    # Description affichée au début du formulaire. Par défaut celui de
    # l'habilitation est prise.
    description: Une description du formulaire
    # Nom de la classe du modèle associé (défini dans l'étape 2). Permet de
    # faire le lien avec la définition plus haut
    authorization_request: MonAPI
    # Optionnel : Permet de spécifier la vue à utiliser dans le cas d'un
    # formulaire sur une seule page. Cette vue doit être placée dans `app/views/authorization_request_forms`
    single_page_view: 'api_entreprise_through_editor'
    # Optionnel. Prend celui de l'habilitation par défaut (même définition
    # qu'au-dessus)
    public: true
    # Optionnel. Prend celui de l'habilitation par défaut (même définition
    # qu'au-dessus)
    startable_by_applicant: true
    # Optionnel. Identifiant (actuellement lié à aucune autre modèle) permettant
    # de potentiellement effectuer des filtres avec des liens directs
    # (exemple : https://api-entreprise.v2.datapass.api.gouv.fr/demandes/api_entreprise/formulaires?use_case=marches_publics)
    # Celui-ci sera plus exploité dans des itérations futures (en l'associant à
    # un vrai modèle)
    use_case: 'marches_publics'
    # Optionnel. Identifiant associé à un fournisseur de données (défini en 1.1
    # ci-dessous)
    service_provider_id: mon-fournisseur
    # Optionnel. Permet d'avoir un texte d'introduction avant de commencer le
    # formulaire. Celui-ci s'affiche après le choix du formulaire et avant la
    # première étape. La page où se situe cette introduction est
    # systématiquement affichée, si l'introduction du formulaire est vide la
    # section est vide.
    # Il est possible d'utiliser les variables `service_provider_name` et `form_name`, de
    # la manière suivante : "L'éditeur %{service_provider_name}".
    introduction: |
      Je suis une introduction permettant d'introduire le formulaire dans ses
      détails.
    # Optionnel. Permet de définir des options sur les scopes de la définition
    # au sein du formulaire. Une docu plus complète est disponible dans
    # ../docs/scopes_config.md
    scopes_config:
      # Optionnel. Scopes (par valeur) qui auront leur checkbox désactivés. À
      # noter que le scope peut être présent (grace à la clé `initialize_with`) ci-dessous.
      disabled:
        - scope1
        - scope2
      # Optionnel. Scopes (par valeur) qui seront masqués/cachés dans le formulaire.
      # Cette option prend la précédence sur `displayed` - si un scope est dans
      # `hide`, il ne sera pas affiché même s'il est dans `displayed`.
      hide:
        - scope5
        - scope6
      # Optionnel. Scopes (par valeur) qui seront affichés. Si cette clé est
      # omise l'ensemble des scopes de la définition sont affichés.
      # Note: Si `hide` est configuré, il prend la précédence sur cette liste.
      displayed:
        - scope3
        - scope4
    # Optionnel. Détermine les étapes ordonnées pour remplir ce formulaire. Si
    # ce champ n'est pas défini le formulaire sera sur une seule page pour le
    # demandeur. La dernière étape est
    # systématiquement le récapitulatif et les cases à cocher des CGUs.
    steps:
      - name: basic_infos
      - name: personal_data
    # Détermine les blocs qui sont statiques, à afficher dans le résumé.
    # Un bloc statique est un bloc qui n'a pas vocation à être modifié par le
    # demandeur, par exemple dans le cas de formulaires d'éditeurs, certaines
    # infos comme les infos du projet sont déjà connues et fixes.
    # Ces blocs doivent matcher sur la clé `name` avec les `blocks` des
    # définitions ci-dessus
    static_blocks:
      - name: basic_infos
    # Optionnel. Données pré-rempli au démarrage du formulaire.
    initialize_with:
      intitule: "Mon intitulé"
```

### 1.1 Ajout d'un nouveau fournisseur (Data Provider)

**⚠️ Important** : Depuis la migration (PR #1175), les Data Providers sont stockés en base de données et non plus dans un fichier YAML.

Pour ajouter un nouveau fournisseur de données, vous avez deux options :
- **En console Rails** : Création manuelle directe (dev/test)
- **Via migration** : Création via fichier de migration (production, recommandé)

**📖 Consulter la documentation complète** : [Ajout d'un nouveau Data Provider](./ajout_nouveau_provider.md)

Cette documentation couvre :
- Conventions de nommage du slug
- Création en console et via migration
- Ajout au fichier seeds et à la factory
- Gestion des logos
- Validations et troubleshooting

**Note** : Le `slug` du provider doit correspondre à la valeur du champ `provider:` dans la configuration `AuthorizationDefinition` ci-dessus.

### 1.2 Ajout d'un Service Provider (éditeur/SaaS)

Les Service Providers (éditeurs et SaaS) sont configurés dans le fichier [`config/service_providers.yml`](../config/service_providers.yml).

```yaml
  # Identifiant unique du service provider (utilisé dans service_provider_id des formulaires)
  mon_editeur:
    # Type : 'editor' pour un éditeur, 'saas' pour un SaaS
    type: editor
    # Nom affiché
    name: Mon Éditeur
    # Optionnel. SIRET de l'organisation
    siret: "12345678900001"
    # Optionnel. Liste des APIs pour lesquelles l'éditeur est déjà intégré
    already_integrated:
      - api_entreprise
    # Optionnel. Indique si l'éditeur est certifié FranceConnect. Par défaut : false
    fc_certified: true
```

Le modèle `ServiceProvider` expose les méthodes suivantes :
- `editor?` : retourne `true` si le type est `editor`
- `saas?` : retourne `true` si le type est `saas`
- `already_integrated?(scope:)` : retourne `true` si l'éditeur est déjà intégré pour le scope donné
- `france_connect_certified?` : retourne `true` si `fc_certified` est `true`

## 2. Ajouter et configurer le modèle de données

En reprenant l'exemple ci-dessus, il faut créer le fichier
`app/models/authorization_request/mon_api.rb` avec le contenu (minimal) suivant :

```ruby
class AuthorizationRequest::MonAPI < AuthorizationRequest
end
```

Certains formulaires possèdent des blocs communs, certains de ces blocs ont été
identifiés et placés dans le dossier
[`app/models/concerns/authorization_extensions`](../app/models/concerns/authorization_extensions).

De manière plus bas niveau, une liste de méthode disponibles pour ajouter des attributs au formulaire :

* `add_attribute :attribut1` pour ajouter un attribut ayant pour nom `attribut1`
    de type texte ;
* `add_documents :document1, validation_options` pour ajouter un document ayant
    pour nom `document1`
* `contact :mon_contact` pour ajouter un nouveau contact. Cette méthode va créer
    les attributs `mon_contact_family_name`, `mon_contact_given_name`,
    `mon_contact_email`, `mon_contact_phone_number`, `mon_contact_job_title`
* `add_scopes`, qui permet d'activer les scopes (basé sur le fichier de config)

Il est fortement conseillé d'utiliser les blocs dans un premier temps, et
ces méthodes outils dans un second temps, qui permettent de dynamiquement
accepter les modifications lors du cycle de vie de la demande, et de
préconfigurer plus rapidement les vues.

Exemple :

```ruby
class AuthorizationRequest::MonAPI < AuthorizationRequest
  include AuthorizationExtensions::CadreJuridique

  add_attribute :intitule
  validates :intitule, presence: true

  contact :responsable_technique

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
end
```

Vis-à-vis de la factory, il faut se rendre dans le fichier
[`spec/factories/authorization_requests.rb`](../spec/factories/authorization_requests.rb) et compléter avec le nom de la classe en underscore.

## 3. Configurer les formulations via l'I18n

Il faut à minima définir les noms des attributs définis dans le modèle. Cela se
passe dans le fichier de locale [`activerecord.fr.yml`](../config/locales/activerecord.fr.yml)).
Ceux-ci servent quand il y a des problèmes de validation sur les attributs.

Concernant les formulaires, l'affichage tire les valeurs dans cet ordre :

1. Dans le fichier de traduction [`authorization_request_forms.fr.yml`](config/locales/authorization_request_forms.fr.yml),
   clé correspondant au type de formulaire (exemple: `mon-api-form`) ;
1. Dans le fichier de traduction [`authorization_request_forms.fr.yml`](config/locales/authorization_request_forms.fr.yml),
   clé correspondant au type d'habilitation (exemple: `mon_api`) ;
1. Dans le fichier de traduction [`authorization_request_forms.fr.yml`](config/locales/authorization_request_forms.fr.yml),
   clé `default`
1. Attributs (dans [`activerecord.fr.yml`](../config/locales/activerecord.fr.yml))

Ce qui est exploité ici (liste non-exhaustive):

1. Les labels
2. Les 'hints' des formulaires
3. Les titres
4. Les blocs d'infos

À noter que l'on peut ajouter d'autres clés non-conventionnelles.

À noter que pour le point 4., les contacts sont définis de manière unitaire, si
vous voulez par exemple modifier ou ajouter des infos sur le contact
`contact_technique` pour le modèle `MonAPI`:

```yaml
authorization_request_forms:
  mon_api:
    contact_technique:
      info: |
        Info sur mon contact technique
```

Il est possible, uniquement pour les infos des contacts, de modifier par
formulaire. Par exemple pour le formulaire ayant l'id "mon-formulaire" pour
le type d'habilitation "mon_api" :

```yaml
authorization_request_forms:
  mon_formulaire:
    contact_technique:
      info: |
        Info sur mon contact technique spécifie à  mon_formulaire
```

## 4. Ajouter la vue de complétion côté demandeur

### Personnalisation du démarrage

S'il n'y a qu'un seul formulaire associé à la définition, alors on redirige directement vers le `new` du formulaire, c'est-à-dire `/formulaires/:form_uid/demande/nouveau`.

S'il y a plusieurs formulaires il y a par défaut la liste de formulaires générique de `authorization_requests/new/default.html.erb`. Il est possible de personnaliser cette page afin par exemple d'effectuer de l'aiguillage.

C'est le cas pour API Entreprise, dont le fichier est présent [ici](../app/views/authorization_requests/new/api_entreprise.html.erb)

Si vous avez besoin de faire la même chose pour un autre type d'habilitation, il
suffit de créer une vue dans le dossier
[`app/views/authorization_requests/new/`] avec le nom en underscore du type d'habilitation.

Pour API Entreprise => `api_entreprise.html.erb`

### 4.1 Cas du multi étapes

Il faut s'assurer que pour chaque étape définie dans le fichier en 1. Une vue
existe dans le dossier [`app/views/authorization_request_forms/build/`](../app/views/authorization_request_forms/build/).

Si ce n'est pas le cas, il faut ajouter, pour une étape ayant pour nom
`mon_etape`, le fichier `mon_etape.html.erb`. Inspirez-vous des fichiers
existants[^1]. Vous pouvez utiliser les méthodes de formulaire en `dsfr_` pour
simplifier la génération des formulaires.

[^1]: il est désormais possible de surcharger le rendu d'un block (de formulaire comme de résumé) en créant un partial sous un dossier nommé avec l'identifiant de la définition (par exemple: le block de "contacts" est surchargé pour les demandes "api_impot_particulier"). Quand cela n'est pas nécessaire le partial sous `default` est alors rendu. cf les méthodes `render_custom_form_or_default` et `render_custom_block_or_default`.

### 4.2 Cas du formulaire sur une page

Il faut créer le fichier `mon_api.html.erb` dans le dossier
[`app/views/authorization_request_forms/`](../app/views/authorization_request_forms/) avec le markup minimal :

```erb
<%= authorization_request_form(@authorization_request) do |f| %>
  <% # Les autres champs ici %>

  <%= render partial: 'authorization_request_forms/shared/tos_checkboxes', locals: { f: } %>
  <%= render partial: 'authorization_request_forms/shared/submit_buttons', locals: { f: } %>
<% end %>
```

À noter qu'il est possible de changer le nom de `mon_api` si vous précisez une
valeur pour `single_page_view`

## 5. Ajout du test d'intégration Cucumber

Créer le fichier `mon_api.feature` dans [`features/habilitations`](../features/habilitations) et
remplissez en fonction de la spécification.

À noter qu'il peut déjà exister des fichiers si le type d'habilitation existait
déjà avant.

## 6. Importer les données existantes

S'il s'agit d'un nouveau formulaire sans donnée, il n'y a rien à faire.
Sinon, vous pouvez vous référer au [README](../app/migration/README.md) associé.
