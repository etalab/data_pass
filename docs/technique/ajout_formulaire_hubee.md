# Ajouter un formulaire d’abonnement HubEE

Le formulaire « Signalements impayés de loyer » (`hubee_impayes_loyer`, code de
démarche `SIMPLO`) sert de modèle : il reprend CertDC et y ajoute les contacts
DPO et RSSI.

## Ce qu’il faut créer

1. Le modèle `AuthorizationRequest::HubEE<Nom>` avec ses contacts. L’adresse
   e-mail nominative se demande avec `required_personal_email: true`, la fonction
   se retire avec `except: %w[job_title]`.
2. Le pont `HubEE<Nom>Bridge` (hérite de `HubEEBaseBridge`) qui crée
   l’organisation puis l’abonnement avec le `processCode` de la démarche.
3. Le notifier `HubEE<Nom>Notifier` (`kind`), le gabarit
   `app/views/hubee_mailer/administrateur_metier_<kind>.text.erb`, le sujet dans
   `HubEEMailer#subject_for` et les gabarits `approve` / `reopening_approve`.
4. La définition (`config/authorization_definitions/hubee.yml`), le formulaire
   (`config/authorization_request_forms/others.yml`), la vue
   `app/views/authorization_request_forms/hubee_<nom>.html.erb` et les textes
   dans `config/locales/authorization_request_forms.fr.yml`.
5. Le fournisseur de données (`DataProvider`) en base, via une migration si le
   fournisseur n’existe pas encore (voir `CreateCnafDataProvider`).

## Formulaire confidentiel

`public: false` sur la définition retire le formulaire du catalogue. Il reste
accessible par son lien direct : `/formulaires/<form_uid>/demande/nouveau`.

## Contact RSSI

Le contact `rssi` n’est déclaré que sur le modèle `HubEEImpayesLoyer`. Sa
généralisation aux autres formulaires est traitée à part (DPP-3).
