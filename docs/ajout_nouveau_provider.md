# Data Providers Documentation

## Table des matières

1. [Introduction](#introduction)
2. [Conventions de nommage du slug](#conventions-de-nommage-du-slug)
3. [Créer un nouveau Data Provider](#créer-un-nouveau-data-provider)
4. [Modifier un Data Provider](#modifier-un-data-provider)
5. [Supprimer un Data Provider](#supprimer-un-data-provider)
6. [Validations](#validations)
7. [Rake tasks](#rake-tasks)
8. [FAQ](#faq)

## Introduction

Un **Data Provider** est une organisation qui fournit des APIs via DataPass (DGFIP, DINUM, URSSAF, etc.).

**Migration (PR #1175)** : Les Data Providers sont maintenant stockés en base de données avec Active Storage pour les logos, au lieu d'un fichier YAML statique.

### Schéma

```
DataProvider
├── slug (string, unique) ← Identifiant technique
├── name (string)         ← Nom d'affichage
├── link (string)         ← URL du site
└── logo (ActiveStorage)  ← PNG ou JPEG
```

## Conventions de nommage du slug

### Qu'est-ce que le slug ?

Identifiant technique unique qui sert à :
- Identifier le provider dans les URLs (FriendlyId)
- Lier avec les `AuthorizationDefinition`
- Clé stable dans le système

### Règles

✅ **À FAIRE :**
- Minuscules : `dgfip`, `dinum`
- Underscores pour séparer : `ministere_des_armees`
- Acronyme officiel si disponible
- Pas d'accents : `ministere` pas `ministère`

❌ **À ÉVITER :**
- Majuscules, tirets, espaces, accents, caractères spéciaux

### Exemples

| Slug | Name |
|------|------|
| `dgfip` | DGFIP |
| `dinum` | DINUM |
| `ministere_des_armees` | Ministère Des Armées |

### ⚠️ IMPORTANT

Le slug **doit correspondre** au slug dans les fichiers YAML des `AuthorizationDefinition` :

```yaml
# config/authorization_definitions/api_impot_particulier.yml
provider: dgfip  # ← Doit correspondre au DataProvider.slug
```

Vérifier avant de créer :
```ruby
AuthorizationDefinition.all.select { |ad| ad.provider.nil? }
```

**Le slug ne doit JAMAIS être modifié** après création !

## Créer un nouveau Data Provider

### 1. Préparer le logo

```bash
# Copier le logo dans le bon répertoire
cp /path/to/logo.png app/assets/images/data_providers/nouveau_provider.png
```

**Format :** PNG ou JPEG | **Taille :** 200x200px minimum

### 2. Créer en console

```ruby
rails console

provider = DataProvider.new(
  slug: 'nouveau_provider',
  name: 'Nouveau Provider',
  link: 'https://nouveau-provider.gouv.fr'
)

provider.logo.attach(
  io: File.open(Rails.root.join('app/assets/images/data_providers/nouveau_provider.png')),
  filename: 'nouveau_provider.png',
  content_type: 'image/png'
)

provider.save!
```

### 3. Ajouter au fichier seeds

Éditer `db/seeds/data_providers.yml` :

```yaml
shared:
  nouveau_provider:
    name: Nouveau Provider
    logo: nouveau_provider.png
    link: https://nouveau-provider.gouv.fr
```

Tester : `Seeds.new.create_data_providers`

### 4. Ajouter à la factory (optionnel)

Éditer `spec/factories/data_providers.rb` :

```ruby
trait :nouveau_provider do
  slug { 'nouveau_provider' }
  name { 'Nouveau Provider' }
  link { 'https://nouveau-provider.gouv.fr' }
end
```

Utiliser : `create(:data_provider, :nouveau_provider)`

### Via migration (production)

```ruby
# db/migrate/YYYYMMDDHHMMSS_add_nouveau_provider.rb
class AddNouveauProvider < ActiveRecord::Migration[8.0]
  def up
    provider = DataProvider.find_or_initialize_by(slug: 'nouveau_provider')
    provider.assign_attributes(
      name: 'Nouveau Provider',
      link: 'https://nouveau-provider.gouv.fr'
    )
    provider.logo.attach(
      io: Rails.root.join('app/assets/images/data_providers/nouveau_provider.png').open,
      filename: 'nouveau_provider.png',
      content_type: 'image/png'
    )
    provider.save!
  end

  def down
    DataProvider.find_by(slug: 'nouveau_provider')&.destroy
  end
end
```

## Modifier un Data Provider

### Modifier attributs

```ruby
provider = DataProvider.friendly.find('dgfip')

# Nom
provider.update!(name: 'Nouveau nom')

# Lien
provider.update!(link: 'https://nouvelle-url.gouv.fr')

# Logo
provider.logo.purge
provider.logo.attach(
  io: File.open(Rails.root.join('app/assets/images/data_providers/nouveau_logo.png')),
  filename: 'nouveau_logo.png',
  content_type: 'image/png'
)
provider.save!
```

### ⚠️ Ne PAS modifier le slug

Si absolument nécessaire :
1. Chercher toutes les références : `grep -r "provider: ancien_slug" config/`
2. Mettre à jour tous les YAML
3. Redéployer
4. Modifier le slug en base

## Supprimer un Data Provider

### Vérifications

```ruby
provider = DataProvider.friendly.find('provider_slug')

provider.authorization_definitions  # => Doit être vide []
provider.instructors.any?           # => false
provider.reporters.any?             # => false
```

### Suppression

```ruby
provider = DataProvider.friendly.find('provider_slug')

# Si tout est OK
provider.destroy!
```
## Gestion des logos

### Formats acceptés

- **PNG** (recommandé) : `image/png`
- **JPEG/JPG** : `image/jpeg`

### Taille recommandée

- Minimum : **200x200px**
- Recommandé : **400x400px**
- Format : Carré ou logo adaptatif

### Emplacement des fichiers

Les logos sources doivent être dans :
```
app/assets/images/data_providers/
├── dgfip.jpeg
├── dinum.png
├── ans.png
└── ...
```

## Validations

| Champ | Validation |
|-------|-----------|
| `slug` | Présence, unicité |
| `name` | Présence |
| `link` | Présence, format URL valide |
| `logo` | Attaché, PNG ou JPEG |

## Rake tasks

```bash
# Lister tous les providers
rails data_providers:list

# Vérifier les logos
rails data_providers:check_logos

# Valider tous les providers
rails data_providers:validate

# Vérifier YAML vs filesystem
rails data_providers:check_yaml_vs_filesystem
```

## FAQ

### Quelle est la différence entre slug et name ?

- **slug** : Identifiant technique unique (ex: `dgfip`), utilisé dans les URLs et les références
- **name** : Nom d'affichage pour l'utilisateur (ex: `DGFIP`), peut contenir majuscules et accents

### Puis-je modifier le slug après création ?

**Non**, le slug est utilisé comme référence dans les `AuthorizationDefinition` et ne doit pas être modifié. Si tu dois vraiment le changer, il faut aussi mettre à jour tous les fichiers YAML qui le référencent.

### Comment vérifier que tous les logos sont bien migrés ?

```bash
rails data_providers:check_logos
```

Ou en console :
```ruby
DataProvider.all.select { |p| !p.logo.attached? }
# => Doit retourner []
```

### Logo ne s'affiche pas ?

```ruby
provider = DataProvider.friendly.find('slug')
provider.logo.attached?              # => true ?
provider.logo.blob.content_type      # => 'image/png' ou 'image/jpeg' ?
```

Si problème, ré-attacher le logo (voir "Modifier un Data Provider").

### Logo SVG ?

Non supporté. Seuls PNG et JPEG sont acceptés.

### Ajouter en production ?

- **Console** : Création manuelle (voir "Créer un nouveau Data Provider")
- **Migration** : Créer une migration dédiée (recommandé)

### Le YAML est encore utilisé ?

Oui, pour référence et `rails db:seed` dans les environnements dev/staging.

## Troubleshooting

### "Slug has already been taken"

```ruby
DataProvider.find_by(slug: 'ton_slug')  # Vérifier si existe
```

### "Logo must be attached"

Attacher le logo avant `save!` :
```ruby
provider.logo.attach(...)
provider.save!
```

### Erreur : "Link is not a valid URL"

L'URL fournie ne respecte pas le format. Elle doit :
- Commencer par `http://` ou `https://` (optionnel)
- Avoir un domaine valide : `example.gouv.fr`
- Pas de caractères invalides

```ruby
# ✅ Valide
'https://www.example.gouv.fr'
'http://example.gouv.fr'
'https://example.gouv.fr/path/to/page'

# ❌ Invalide
'not a url'
'ftp://example.com'
'example'
```

### Le logo ne s'affiche pas après migration

Vérifie que la migration `PopulateDataProviders` a bien été exécutée :
```ruby
DataProvider.count
# => doit retourner le nombre de providers du YAML

DataProvider.all.each do |p|
  puts "#{p.slug}: #{p.logo.attached?}"
end
```

Si des logos manquent :
```bash
rails db:seed
```

### Restaurer depuis YAML

```ruby
DataProvider.destroy_all
Seeds.new.create_data_providers
```

---

**Dernière mise à jour** : 2025-10-27
**Migration** : 2025-10-23 (PR #1175)