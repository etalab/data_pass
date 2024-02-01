# Design

## Base / framework

Le site est basé sur le [Système de Design de
l'État](https://www.systeme-de-design.gouv.fr/)

Les éléments / la documentation se trouvent sur le lien ci-dessus, la recherche
fonctionne assez bien (grid, button etc etc .. tout ça fonctionne)

## Extensions

* [`DSFRFormBuilder`](../app/form_builders/dsfr_form_builder.rb) : custom form
    builder ;
* [Helpers `DSFR`](../app/helpers/dsfr/) : composants
* [Feuille de style d'extensions](../app/assets/stylesheets/dsfr-extensions.css)

## Installation de la dernière version du DSFR

Avant toute chose, [téléchargez la dernière version
disponible](https://github.com/GouvernementFR/dsfr/releases)

Il y a quelques manipulations à respecter pour que cela fonctionne:

Concernant le CSS:

1. Remplacer le fichier `app/assets/stylesheets/dsfr.css` par le fichier du même nom dans `dist/dsfr`
2. Chercher l'ensemble des déclarations des font-face de Marianne et Spectral
   dans le fichier, et le supprimer. En effet c'est le fichier
   `app/assets/stylesheets/dsfr-fonts.scss` qui s'occupe de déclarer les fonts

Concernant le js:

1. Remplacer le fichier `app/javascripts/dsfr.module.js` par le fichier
   du même nom dans `dist/dsfr`

Concernant les [icônes](https://www.systeme-de-design.gouv.fr/elements-d-interface/fondamentaux-techniques/icone):

1. Remplacer le fichier `app/assets/stylesheets/dsfr-utility.css` par le fichier `dist/utility/utility.css`
2. Remplacer le dossier `app/assets/icons` par le dossier `dist/icons`
3. Dans les fichiers `dsfr-utility.css` et `dsfr.css`, remplacez tous les liens
   des icones de `../icons/whatever` en `icons/whatever`

Concernant les [pictogrammes](https://www.systeme-de-design.gouv.fr/elements-d-interface/fondamentaux-techniques/pictogramme):

1. Remplacer le dossier `app/assets/artwork` par le dossier `dist/artwork`
