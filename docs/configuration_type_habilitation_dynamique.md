# Configurer un type d'habilitation dynamique

Ce document est à destination des utilisateurs qui créent ou modifient
des types d'habilitation depuis l'interface d'administration de DataPass.

Pour la documentation technique, voir [Système `HabilitationType` dynamique](./habilitation_type_dynamique.md).

## Pourquoi un système dynamique ?

Avant, ajouter ou modifier un type d'habilitation passait par un fichier de
configuration YAML et nécessitait l'intervention d'un développeur ainsi qu'un
déploiement. Désormais, vous pouvez créer et faire évoluer un type d'habilitation
directement depuis l'interface d'administration, et la modification est prise en
compte immédiatement, sans dev pour les actions courantes. Les types historiques
(YAML) et les types dynamiques (administrables) cohabitent : pour le demandeur
comme pour l'instructeur, l'expérience est strictement la même.

## Ce que vous pouvez configurer sans développeur

Depuis l'interface d'administration, vous pouvez :

- créer un nouveau type d'habilitation rattaché à un fournisseur de données
  existant ;
- choisir les blocks à afficher dans le formulaire de demande ;
- définir les scopes (les données accessibles via l'API) ;
- configurer les types de contacts requis pour la demande ;
- activer ou désactiver des fonctionnalités (messagerie, transfert, réouverture) ;
- modifier le nom, la description et le bandeau d'introduction du formulaire ;
- mettre à jour les liens documentaires (CGU, doc d'accès) et l'adresse de
  support exposée aux demandeurs.

## Blocks disponibles

Un block est une section du formulaire de demande. Voici les blocks que vous
pouvez activer depuis l'interface d'administration :

| Block | Ce qu'il ajoute au formulaire | Champs côté demandeur |
| --- | --- | --- |
| `basic_infos` | Étape « Informations de base » du formulaire | Intitulé de la demande, description |
| `cadre_juridique` (alias `legal`) | Étape « Cadre juridique » | URL du texte de référence ou document PDF, nature du cadre juridique |
| `personal_data` | Étape « Données à caractère personnel » | Destinataires des données, durée de conservation, justifications associées |
| `scopes` | Étape « Données accessibles » | Cases à cocher des scopes définis sur le type |
| `contacts` | Étape « Contacts » | Pour chaque contact requis : nom, prénom, email, téléphone, fonction |
| `cnous_data_extraction_criteria` (en cours) | Non visible dans le wizard pour l'instant | Block configuré côté backend mais pas encore livré pour les demandeurs |

Les blocks `basic_infos`, `cadre_juridique` et `personal_data` sont
pré-sélectionnés à la création d'un nouveau type — ils correspondent au socle
minimum d'une demande d'habilitation.

## Configurer les scopes

Un scope correspond à une donnée (ou à un ensemble de données) accessible via
l'API. Côté demandeur, les scopes sont présentés sous forme d'une liste de
cases à cocher : il sélectionne uniquement ce dont il a besoin.

Pour chaque scope, vous renseignez :

- un **nom affiché** : le libellé que verra le demandeur (par exemple « Adresse
  postale » ou « Quotient familial CAF ») ;
- une **valeur technique** : l'identifiant utilisé par l'API. Cette valeur
  ne peut pas être modifiée après création du scope, pour préserver la
  stabilité de l'API et ne pas casser les intégrations existantes ;
- un **groupe** (optionnel) : permet de regrouper visuellement plusieurs scopes
  liés (par exemple « Identité », « Coordonnées »).

Une fois le scope créé, vous pouvez encore éditer son nom affiché et son groupe.
La valeur technique reste figée.

## Configurer les contacts

Le block `contacts` permet de demander au porteur de la demande d'identifier les
personnes responsables côté son organisation. Vous choisissez les types de
contacts à exiger en fonction du contexte du type d'habilitation.

Types de contacts couramment utilisés :

- **Responsable technique** : la personne qui pilotera l'intégration côté SI ;
- **Responsable de traitement** : la personne juridiquement responsable des
  données traitées ;
- **Délégué à la protection des données (DPO)** ;
- **Responsable métier** ou **chef de projet**.

Pour chaque type de contact ajouté, le formulaire génère automatiquement les
champs suivants : nom, prénom, email, téléphone et fonction. Le demandeur doit
les renseigner pour soumettre sa demande.

## Fonctionnalités activables

Quatre fonctionnalités peuvent être activées indépendamment sur un type
d'habilitation. Chacune change ce que demandeurs et instructeurs peuvent faire
sur les demandes.

- **Messagerie** : permet à l'instructeur et au demandeur d'échanger des
  messages directement depuis la fiche de la demande. Sans cette fonctionnalité,
  les échanges se font hors DataPass.
- **Transfert** : autorise le changement d'organisation porteuse d'une
  habilitation (par exemple en cas de réorganisation administrative). Sans cette
  option, la demande reste rattachée à l'organisation initiale.
- **Réouverture** : permet à un demandeur de reprendre une demande déjà
  approuvée pour la modifier (par exemple ajouter un scope). Sans cette
  fonctionnalité, toute évolution passe par une nouvelle demande.
- **Templates de messages** : met à disposition des instructeurs des modèles de
  réponses standardisées (refus, demande de modification, validation) qu'ils
  peuvent réutiliser et personnaliser. Voir [docs/templates_messages.md](./templates_messages.md).

## Ce qui nécessite encore un développeur

Certaines évolutions ne sont pas (encore) couvertes par l'interface
d'administration et passent par un dev :

- **Créer un block entièrement nouveau** : un block qui n'existe pas déjà dans
  le catalogue (par exemple un block « volumétrie » ou « certification de
  sécurité ») doit être implémenté côté code (concern, vues, libellés
  internationalisés). La procédure est documentée dans
  [ajout_block_dynamique.md](./ajout_block_dynamique.md).
- **Modifier les libellés par défaut des champs** : les noms et textes d'aide
  des champs des blocks suivent une formulation par défaut. Pour la
  personnaliser sur un type donné, il faut passer par les fichiers de
  traduction.
- **Préremplir un formulaire** (par cas d'usage ou par éditeur) : le mécanisme
  qui pré-remplit certains champs en fonction du contexte n'est pas encore
  disponible côté dynamique. Il reste réservé aux types historiques YAML.
- **Renommer le slug d'un type existant** : changer l'identifiant technique
  d'un type a des répercussions dans plusieurs tables (demandes, rôles,
  réglages utilisateurs) et impose une migration de données coordonnée.
- **Ajouter un fournisseur de données (Data Provider)** : la liste des
  fournisseurs auxquels un type peut être rattaché est gérée côté code.

## Limitations connues

- **Préremplissage** (par cas d'usage ou par éditeur partenaire) : disponible
  uniquement pour les types YAML historiques, pas encore implémenté côté
  dynamique.
- **Block `cnous_data_extraction_criteria`** : configuré en backend mais ses
  vues côté demandeur ne sont pas encore livrées. Il n'apparaît donc pas dans
  le wizard et ne doit pas être activé sur un type en production tant que les
  vues ne sont pas livrées.
- **`custom_labels`** : surface réservée pour de futures personnalisations
  d'étiquettes par type d'habilitation. Non opérationnelle actuellement.
- **Cas d'usage** : un type dynamique n'est pas associé à un cas d'usage
  particulier — toutes les demandes empruntent le même formulaire.

## Pour aller plus loin

- [habilitation_type_dynamique.md](./habilitation_type_dynamique.md) —
  architecture technique du système dynamique (pour les développeurs).
- [ajout_block_dynamique.md](./ajout_block_dynamique.md) — procédure pour
  ajouter un nouveau block au catalogue (dev).
- [templates_messages.md](./templates_messages.md) — fonctionnalité de
  templates de messages côté instructeur.
- [nouveau_type_d_habilitation.md](./nouveau_type_d_habilitation.md) — ajout
  d'un type d'habilitation YAML historique (legacy).