# Bannière d'annonce

## Définition

La bannière d'annonce (`AnnouncementBanner`) affiche un message d'information sur
toutes les pages de l'application pendant une fenêtre de temps donnée. Elle est
utilisée pour prévenir les utilisateurs d'une interruption de service planifiée
(ex. : maintenance ProConnect).

## Configuration

Éditer [`config/announcement_banner.yml`](../config/announcement_banner.yml) :

```yaml
shared:
  start: "2026-04-23 14:00"
  end: "2026-04-23 19:30"
  title: "Maintenance ProConnect ce soir à 18h"
  description: "Message affiché sous le titre."
```

Les dates sont parsées par [Chronic](https://github.com/mojombo/chronic) et
acceptent des formats lisibles comme `"2026-04-23 14:00"` ou `"april 23 2026 at 2pm"`.
Les heures sont interprétées dans le fuseau horaire du serveur.

## Désactiver la bannière

Laisser `start` ou `end` vides suffit à désactiver l'affichage :

```yaml
shared:
  start:
  end:
  title: ""
  description: ""
```

La bannière est visible uniquement si `Time.zone.now` est compris entre `start`
et `end`. En dehors de cette fenêtre, rien n'est rendu.
