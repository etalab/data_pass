# Ajout d'un nouveau fournisseur

La checklist globale:

1. Ajouter le ou les entrée(s) dans les fichiers de config ;
2. Ajouter et configurer le modèle (avec sa factory et son test) ;
3. Configurer les formulations via l'I18n ;
4. Ajouter la vue de complétion côté demandeur ;
5. Ajouter un test d'intégration Cucumber ;
6. Importer les données existantes.

Disclaimer: La procédure est amené à évoluer rapidement, et certains parties seront
peut-être obsolètes. Il y a par ailleurs des refactorisations logiques, mais
potentiellement prématurés: il faut attendre d'intégrer plus de sources pour
être sûr d'effectuer les refactorisations nécessaires.

## 1. Fichiers de configurations

Une demande d'habilitation (le modèle) est lié à 1 ou plusieurs formulaires. Il
faut à minima en remplir 1 de chaque et qu'ils soient liés.

Pour [le modèle](../config/authorization_definitions.yml):

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
    # Optionel. Lien pour en savoir plus. Par défaut le lien du fournisseur est pris
    link: https://mon-api.gouv.fr
    # Lien vers les CGU
    cgu_link: https://mon-api.gouv.fr/cgu.pdf
    # Affiche ou non cette source de données dans l'index des formulaires
    public: true
    # Optionnel. Détermine si il ne peut y avoir qu'un seul formulaire par organisation. Par défaut à `false`
    unique: false
    # Optionel. Détermine si ce formulaire peut être démarrer à l'initiative de
    # l'utilisateur. Cet attribut sert principalement aux habilitations en 2
    # étapes (bac à sable puis production), lorsque la 1ere est validé la 2e est
    # crée par le système. Par défaut à `true`
    startable_by_applicant: false
    # Liste des diverses données débrayable pour la source de données
    scopes:
        # Nom humanisé de la donnée
      - name: Nom de famille
        # Nom technique de la donnée
        value: family_name
        # Optionnel. Nom du groupe pour cette donnée afin d'effectuer
        # un regroupement visuel
        group: Identité pivot
        # Optionnel. Lien vers des détails sur la donnée. Affiche un lien pour
        # en savoir plus sur cette donnée.
        link: https://mon-api.gouv.fr/documentation/nom-de-famille
        # Optionnel. Détermine si la donnée est forcément incluse. Cela permet
        # d'afficher des données grisés et cochés à l'utilisateur pour l'informer
        # que ces données seront disponibles avec son habilitation. Par défaut à
        # false
        included: true
    # Liste des blocs à afficher dans le résumé
    # Ces blocs peuvent correspondre aux 'steps' des formulaires définis
    # ci-dessous, mais ce n'est pas une obligation. Chaque bloc doit être défini
    # dans app/views/authorization_requests/shared/blocks/
    blocks:
      - name: basic_infos
      - name: personal_data
```

Pour [le formulaire](../config/authorization_request_forms.yml):

```yaml
  # Identifiant unique qui sera utilisé dans les URLs
  mon-api:
    # Nom affiché en titre du formulaire. Par défaut celui de l'habilitation est
    # prise
    name: Mon API dans le formulaire
    # Description affichée au début du formulaire. Par défaut celui de
    # l'habilitation est prise.
    description: Une description du formulaire
    # Nom de la classe du modèle associé (défini dans l'étape 2). Permet de
    # faire le lien avec la définition plus haut
    authorization_request: MonAPI
    # Optionnel. Prend celui de l'habilitation par défaut
    public: true
    # Optionnel. Prend celui de l'habilitation par défaut
    startable_by_applicant: true
    # Optionnel. Données pré-rempli au démarrage du formulaire.
    data:
      intitule: "Mon intitulé"
    # Optionnel. Détermine les étapes ordonnées pour remplir ce formulaire. Si
    # ce champ n'est pas défini le formulaire sera sur une seule page pour le
    # demandeur. La dernière étape est
    # systématiquement le récapitulatif et les cases à cocher des CGUs.
    steps:
      - name: basic_infos
      - name: personal_data
    # Détermine les blocs qui sont statiques, à afficher dans le résumé.
    # Un bloc statique est un bloc qui n'a pas vocation a être modifié par le
    # demandeur, par exemple dans le cas de formulaires d'éditeurs, certaines
    # infos comme les infos du projet sont déjà connues et fixes.
    # Ces blocs doivent matcher sur la clé `name` avec les `blocks` des
    # définitions ci-dessus
    static_blocks:
      - name: basic_infos
```

### 1.1 Ajout d'un nouveau fournisseur

Si il s'agit d'un nouveau fournisseur, il faut l'ajouter dans
[`config/data_providers.yml`](../config/data_providers.yml)

Le format:

```yaml
  # Identifiant unique du fournisseur, utilisé dans le form au dessus
  mon-fournisseur:
    name: Mon Fournisseur
    logo: mon-fournisseur.png
    link: https://mon-fournisseur.gouv.fr
```

## 2. Ajouter et configurer le modèle de données

En reprenant l'exemple ci-dessus, il faut créer le fichier
`app/models/authorization_request/mon_api.rb` avec le contenu (minimal) suivant:

```ruby
class AuthorizationRequest::MonAPI < AuthorizationRequest
end
```

Certains formulaires possèdent des blocs communs, certains de ces blocs ont été
identifiés et placés dans le dossier
[`app/models/concerns/authorization_extensions`](../app/models/concerns/authorization_extensions).

De manière plus bas niveau, une liste de méthode disponibles pour ajouter des attributs au formulaire:

* `add_attribute :attribut1` pour ajouter un attribut ayant pour nom `attribut1`
    de type texte ;
* `add_document :document1, validation_options` pour ajouter un document ayant
    pour nom `document1`
* `contact :mon_contact` pour ajouter un nouveau contact. Cette méthode va créer
    les attributs `mon_contact_family_name`, `mon_contact_given_name`,
    `mon_contact_email`, `mon_contact_phone_number`, `mon_contact_job_title`
* `add_scopes`, qui permet d'activer les scopes (basé sur le fichier de config)

Il est fortement conseillé d'utiliser les blocs dans un premier temps, et
ces méthodes outils dans un second temps, qui permettent de dynamiquement
accepter les modifications lors du cycle de vie de la demande, et de
pré-configurer plus rapidement les vues.

Exemple:

```ruby
class AuthorizationRequest::MonAPI < AuthorizationRequest
  include AuthorizationExtensions::CadreJuridique

  add_attribute :intitule
  validates :intitule, presence: true

  contact :responsable_technique

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
end
```

Vis-à-vis de la factory, il faut se rendre dans le fichier
[`spec/factories/authorization_requests.rb`](../spec/factories/authorization_requests.rb) et compléter avec le nom de la classe en underscore.

## 3. Configurer les formulations via l'I18n

Il faut à minima définir les noms des attributs définis dans le modèle. Cela se
passe dans le fichier de locale [`activerecord.fr.yml`](../config/locales/activerecord.fr.yml)).
Ceux-ci servent quand il y a des problèmes de validation sur les attributs.

Concernant les formulaires, l'affichage tire les valeurs dans cet ordre:

1. Dans le fichier de traduction [`authorization_request_forms.fr.yml`](config/locales/authorization_request_forms.fr.yml),
   clé correspondant au type de formulaire (exemple: `mon_api`)
2. Dans le fichier de traduction [`authorization_request_forms.fr.yml`](config/locales/authorization_request_forms.fr.yml),
   clé `default`
3. Attributs (dans [`activerecord.fr.yml`](../config/locales/activerecord.fr.yml))

Ce qui est exploité ici (liste non-exhaustive):

1. Les labels
2. Les 'hints' des formulaires
3. Les titres
4. Les blocs d'infos

A noter que l'on peut ajouter d'autres clés non-conventionnelles (exemple pour
API Infinoe Production).

A noter que pour le point 4., les contacts sont définis de manière unitaire, si
vous voulez par exemple modifier ou ajouter des infos sur le contact
`contact_technique` pour le modèle `MonAPI`:

```yaml
authorization_request_forms:
  mon_api:
    contact_technique:
      info: |
        Info sur mon contact technique
```

## 4. Ajouter la vue de complétion côté demandeur

### Personnalisation du démarrage

Après la page où l'on rappelle l'organisation, il y a une page de sélection de
formulaire. Si il y a plusieurs formulaires il y a par défaut une liste de
formulaires générique. Il est possible de personnaliser cette page afin
par exemple d'effectuer de l'aiguillage.

C'est le cas pour API Entreprise, dont le fichier est présent [ici](../app/views/authorization_request_forms/index/_api_entreprise.html.erb)

Si vous avez besoin de faire la même chose pour un autre type d'habilitation, il
suffit de créer une vue partielle dans le dossier
[`app/views/authorization_request_forms/index/`] avec le nom en underscore du
type d'habilitation.

Pour API Entreprise => `_api_entreprise.html.erb`

### 4.1 Cas du multi étapes

Il faut s'assurer que pour chaque étape défini dans le fichier en 1. une vue
existe dans le dossier [`app/views/authorization_request_forms/shared/`](../app/views/authorization_request_forms/shared/).

Si ce n'est pas le cas il faut ajouter, pour une étape ayant pour nom
`mon_etape`, le fichier `_mon_etape.html.erb`. Inspirez-vous des fichiers
existants. Vous pouvez utiliser les méthodes de formulaire en `dsfr_` pour
simplifier la génération des formulaires.

### 4.2 Cas du formulaire sur une page

Il faut créer le fichier `mon_api.html.erb` dans le dossier
[`app/views/authorization_request_forms/`](../app/views/authorization_request_forms/) avec le markup minimal:

```erb
<%= authorization_request_form(@authorization_request) do |f| %>
  <% # Les autres champs ici %>

  <%= render partial: 'authorization_request_forms/shared/tos_checkboxes', locals: { f: } %>
  <%= render partial: 'authorization_request_forms/shared/submit_buttons', locals: { f: } %>
<% end %>
```

## 5. Ajout du test d'intégration Cucumber

Créer le fichier `mon_api.feature` dans [`features/habilitations`](../features/habilitations) et
remplissez en fonction de la spécification.

## 6. Importer les données existantes

Si il s'agit d'un nouveau formulaire sans donnée, il n'y a rien à faire.
Sinon, vous pouvez vous référer au [README](../app/migration/README.md) associé.
