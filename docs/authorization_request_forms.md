# Demande d'habilitations

## I18n

Pour l'afichage dans les formulaires, on va chercher la traduction dans cet ordre:

1. Attributs (dans
   [`activerecord.fr.yml`](../config/locales/activerecord.fr.yml)): utilisé aussi
   le nom humain des attributs du modèle
2. Dans le fichier de traduction [`authorization_request_forms.fr.yml`](config/locales/authorization_request_forms.fr.yml),
   clé `default`
3. Dans le fichier de traduction [`authorization_request_forms.fr.yml`](config/locales/authorization_request_forms.fr.yml),
   clé correspondant au type de formulaire (exemple: `api_entreprise`)
