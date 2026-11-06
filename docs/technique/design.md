# Design

## Base / framework

Le site est basé sur le [Système de Design de
l'État](https://www.systeme-de-design.gouv.fr/)

Les éléments / la documentation se trouvent sur le lien ci-dessus, la recherche
fonctionne assez bien (grid, button etc etc .. tout ça fonctionne)

## Extensions

* [`DsfrFormBuilder`](.../../app/form_builders/dsfr_form_builder.rb) : custom form
    builder ;
* [Helpers `Dsfr`](.../../app/helpers/dsfr/) : composants
* [Feuille de style d'extensions](.../../app/assets/stylesheets/dsfr-extensions.css)

## Version du DSFR

Le DSFR est servi par la gem [`dsfr-assets`](https://github.com/betagouv/dsfr-assets),
dont le numéro de version suit celui du DSFR. CSS, JavaScript, icônes,
pictogrammes et polices viennent de la gem : le dépôt n’en garde aucune copie.

### Mise à jour

Dependabot propose les nouvelles versions de `dsfr-assets`, déclarée en
dépendance directe dans le `Gemfile`. Avant de fusionner :

1. lire les [notes de version](https://github.com/GouvernementFR/dsfr/releases) ;
2. relancer RSpec et Cucumber ;
3. comparer les pages principales à 1440 et 390 px : la gem change tout le rendu
   d’un coup.

### Licence

La gem bloque le démarrage de l’application tant que ses modalités d’utilisation
ne sont pas acceptées. L’acceptation vit dans
[`config/initializers/dsfr_assets.rb`](../../config/initializers/dsfr_assets.rb).
Si une nouvelle version de la gem exige de nouvelles modalités, l’application
refuse de démarrer : relire les modalités, puis y reporter le numéro demandé.

### Chargement

Dans [`application.html.erb`](../../app/views/layouts/application.html.erb) :

- les CSS sont dans le `<head>` : `dsfr.min`, `dsfr.print.min` (`media: "print"`)
  et `utility/dsfr-utility.min` ;
- le JavaScript est en fin de `<body>` : `dsfr.module.min` en `type="module"` et
  `dsfr.nomodule.min` en `nomodule`, comme le demande la documentation du DSFR.

Un script `type="module"` ne doit jamais être placé avant
`javascript_importmap_tags` : l’importmap devient inopérante et Stimulus démarre
avec environ 3 secondes de retard.

Dans les tests Cucumber, un clic envoyé juste après le chargement sur un bouton
de `fr-collapse` peut être perdu : le DSFR 1.15 ignore un clic reçu dans l’image
qui suit l’initialisation du bouton. L’étape « je clique sur » attend donc cette
initialisation (`wait_for_dsfr_collapse_button`).

### Ce qui reste dans le dépôt

- `app/assets/stylesheets/dsfr-extensions.css`, `components/` et `pages/` : le CSS
  propre à DataPass ;
- `app/assets/images/pictograms/` : les pictogrammes propres à DataPass ;
- `app/assets/images/favicons/` et `public/` : les favicons.

À chemin égal, Propshaft sert le fichier du dépôt avant celui de la gem. Ne pas
recopier d’icône ni de pictogramme du DSFR dans `app/assets/images` : la copie
masquerait les dessins des versions suivantes.
