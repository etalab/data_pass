# Design

## Base / framework

Le site est basé sur le [Système de Design de
l'État](https://www.systeme-de-design.gouv.fr/)

Les éléments / la documentation se trouvent sur le lien ci-dessus, la recherche
fonctionne assez bien (grid, button etc etc .. tout ça fonctionne)
### Installation de la dernière version du DSFr

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

Concernant les icônes:

1. Remplacer le fichier `app/assets/stylesheets/dsfr-utility.css` par le fichier `dist/utility/utility.css`
2. Remplacer le dossier `app/assets/icons` par le dossier `dist/icons`
