# Ajout d'un noveau block de formulaire à étapes

Voici un exemple d'ajout de bloc avec le bloc d'homologation de sécurité d'Impôts Particulier : 
- [Le commit](https://github.com/etalab/data_pass/commit/3ec0fd83f26b2485aba198ae48342440010d4bcb)

On va faire référence à cet exemple dans la suite de cette documentation.

## Pour commencer avec la config du modèle

- Faire le module AuthorizationExtensions dans `app/models/concerns/authorization_extensions/safety_certification.rb` avec les attributs à ajouter (et leur validations, mais ça peut s'ajouter après une fois que tout est branché)
- L'inclure dans le modèle d'`AuthorizationRequest` qui va l'utiliser, ici c'est `app/models/authorization_request/api_impot_particulier.rb`
- Dire à wicked comment nommer la route de ce block dans `config/locales/fr.yml`
- Ajouter le block dans la définition `config/authorization_definitions.yml`
- Ajouter la step dans le form `config/authorization_request_forms/dgfip.yml`

## Ensuite on s'occupe de l'interface

- Ajouter les wordings du block dans `config/locales/authorization_request_forms.fr.yml`
- Ajouter les wordings des champs dans `config/locales/activerecord.fr.yml`
- Faire une partial de form dans `app/views/authorization_request_forms/shared/_safety_certification.html.erb` avec les champs à remplir (séparer cette partial servira à réutiliser le bloc dans des formulaires single page, ou pour l'édition de champs directement dans le summary)
- L'utiliser dans un vue pour la step de formulaire à étapes dans `app/views/authorization_request_forms/build/safety_certification.html.erb`
- Faire une partial de show `app/views/authorization_requests/shared/blocks/_safety_certification.html.erb` pour afficher le block dans le sommaire

## Puis des tests (tu peux commencer par les tests en vrai d'ailleurs)

Il faut mettre à jour la factory du formulaire pour que ses tests restent valides :
- Ajouter la factory `with_safety_certification` dans `spec/factories/authorization_requests.rb`
- L'inclure dans la factory du form qui l'utilise (ici c'est `api_impot_particulier_editeur`)

Il reste plus qu'à ajouter le test e2e, que l'on peut voir pour notre exemple dans [ce commit](https://github.com/etalab/data_pass/commit/fe4c8e9e4770a001d6d71f0cf6861f6fc9e6dd90) :
- Faire la step `Quand("Je renseigne l'homologation de sécurité")`
- L'utiliser dans le fichier de test du formulaire qui l'utilise (ici c'est `features/habilitations/dgfip/api_impots_particuliers_editeur.feature`)


