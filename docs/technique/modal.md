# Modal dynamique

## Vue d'ensemble

Le système de modal dynamique permet de définir la taille d'une modale via des attributs DOM dans les vues, sans nécessiter de logique côté serveur. Cette fonctionnalité s'applique uniquement à la modale principale (`main-modal`).

## Fonctionnement

Le système utilise un contrôleur Stimulus (`dynamic_modal_controller`) qui écoute les événements de chargement Turbo Frame et applique dynamiquement les classes CSS de dimensionnement au conteneur de la modale.

### Architecture

- **Contrôleur Stimulus**: `app/javascript/controllers/dynamic_modal_controller.js`
- **Partial de modal**: `app/views/shared/_modal.html.erb`
- **Événements**: `turbo:frame-load` sur le turbo-frame `main-modal-content`

## Utilisation

### Tailles prédéfinies

Vous pouvez utiliser des tailles prédéfinies via l'attribut `data-modal-size` sur le premier élément enfant du turbo-frame:

```erb
<turbo-frame id="main-modal-content">
  <div data-modal-size="small">
    <!-- contenu de la modale -->
  </div>
</turbo-frame>
```

**Important**: L'attribut `data-modal-size` doit être placé sur le **premier élément enfant** du turbo-frame, pas sur le turbo-frame lui-même. Cela permet à Turbo de charger le contenu sans perdre l'attribut.

#### Tailles disponibles

| Taille | Classes CSS | Usage recommandé |
|--------|-------------|------------------|
| `small` | `fr-col-12 fr-col-md-6 fr-col-lg-4` | Confirmations simples, alertes |
| `medium` | `fr-col-12 fr-col-md-8 fr-col-lg-6` | Taille par défaut |
| `large` | `fr-col-12 fr-col-md-10 fr-col-lg-8` | Formulaires avec plusieurs champs |
| `full` | `fr-col-12` | Contenu nécessitant toute la largeur |

### Classes CSS personnalisées

Pour un contrôle plus précis, utilisez l'attribut `data-modal-size-classes` sur le premier élément enfant:

```erb
<turbo-frame id="main-modal-content">
  <div data-modal-size-classes="fr-col-12 fr-col-md-9 fr-col-lg-7">
    <!-- contenu de la modale -->
  </div>
</turbo-frame>
```

## Exemples

### Exemple 1: Formulaire de refus (taille large)

```erb
<turbo-frame id="main-modal-content">
  <div data-modal-size="large">
    <%= form_with(model: @denial_of_authorization, ...) do |f| %>
      <div class="fr-modal__content">
        <h1 class="fr-modal__title">Refuser la demande</h1>
        <%= f.dsfr_text_area :reason %>
      </div>
      <div class="fr-modal__footer">
        <!-- boutons -->
      </div>
    <% end %>
  </div>
</turbo-frame>
```

### Exemple 2: Confirmation simple (taille par défaut)

```erb
<turbo-frame id="main-modal-content">
  <div>
    <div class="fr-modal__content">
      <h1 class="fr-modal__title">Confirmer l'action</h1>
      <p>Êtes-vous sûr de vouloir continuer ?</p>
    </div>
    <div class="fr-modal__footer">
      <!-- boutons -->
    </div>
  </div>
</turbo-frame>
```

### Exemple 3: Classes personnalisées

```erb
<turbo-frame id="main-modal-content">
  <div data-modal-size-classes="fr-col-12">
    <div class="fr-modal__content">
      <h1 class="fr-modal__title">Vue complète</h1>
      <!-- contenu large -->
    </div>
  </div>
</turbo-frame>
```

## Comportement

### Priorité des attributs

L'ordre de priorité pour déterminer la taille de la modale est:

1. `data-modal-size-classes` (classes personnalisées)
2. `data-modal-size` (taille prédéfinie)
3. Taille par défaut (`fr-col-12 fr-col-md-8 fr-col-lg-6`)

### Rétrocompatibilité

Les vues existantes sans attributs de taille continuent de fonctionner avec la taille par défaut. Aucune modification n'est nécessaire pour maintenir le comportement actuel.

### Changement dynamique

Lorsque vous naviguez entre différents contenus de modale, la taille s'adapte automatiquement en fonction des attributs du nouveau contenu.

## Limitations

- Cette fonctionnalité s'applique **uniquement à la modale principale** (`main-modal`)
- Les autres modales (via `:extra_modal`) conservent leur comportement standard
- Le contrôleur est simple et ne fait pas de validation des valeurs fournies

## Implémentation technique

### Détection du changement de contenu

Le contrôleur utilise deux mécanismes pour détecter les changements:

1. **Événement Turbo**: `turbo:frame-load` sur le turbo-frame
2. **MutationObserver**: Observe les changements DOM dans le turbo-frame

```javascript
connect() {
  this.contentTarget.addEventListener('turbo:frame-load', this.applySizeClasses.bind(this))

  this.observer = new MutationObserver(() => {
    this.applySizeClasses()
  })

  this.observer.observe(this.contentTarget, {
    childList: true,
    subtree: true
  })

  this.applySizeClasses()
}
```

### Application des classes

Le contrôleur:
1. Lit les attributs du premier élément enfant du turbo-frame (priorité 1)
2. Si absent, cherche sur le turbo-frame lui-même (priorité 2)
3. Détermine les classes CSS à appliquer selon l'ordre de priorité:
   - `data-modal-size-classes` (classes personnalisées)
   - `data-modal-size` (taille prédéfinie)
   - Classes par défaut
4. Remplace les classes `fr-col-*` du conteneur par les nouvelles classes

### Code du contrôleur

Le contrôleur complet est disponible dans `app/javascript/controllers/dynamic_modal_controller.js`.

## Références

- [DSFR - Système de grille](https://www.systeme-de-design.gouv.fr/elements-d-interface/fondamentaux-techniques/grille-et-points-de-rupture)
- [DSFR - Composant Modal](https://www.systeme-de-design.gouv.fr/composants-et-modeles/composants/modale-dialog)
- [Stimulus Controllers](https://stimulus.hotwired.dev/)
- [Turbo Frames](https://turbo.hotwired.dev/handbook/frames)
