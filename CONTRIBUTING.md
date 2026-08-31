# Contribuer à DataPass

On a écrit ce document pour se mettre d’accord sur notre façon de travailler :
comment une modification arrive dans le dépôt, ce qu’on met dans une pull
request, et comment on se relit.

Si tu viens d’arriver dans l’équipe, commence par là. Les contributions
externes suivent les mêmes règles.

Rien n’est gravé dans le marbre. Si une règle ne te convient pas, ouvre une
pull request pour la changer, on en discutera.

## 1. Un ticket pour chaque modification

On crée un ticket Linear pour toute modification, même une faute d’orthographe.

Le ticket garde le contexte. L’équipe produit voit ce qui avance sans avoir à
lire le code, et la personne qui tombera sur la modification dans six mois
comprendra pourquoi elle a été faite.

Pour une contribution externe, c’est l’équipe qui crée le ticket.

### Relier la pull request au ticket

Le plus simple est de mettre l’identifiant du ticket dans le nom de la branche,
Linear fait le lien tout seul : `feature/dpp-123-description-courte`.

Sinon, cite le ticket dans la description de la pull request. Linear ne
détecte pas les liens dans les commentaires ni dans les messages de commit.

## 2. Découper son travail

Il n’y a pas de règle stricte, c’est au cas par cas.

On peut regrouper plusieurs tickets dans une même pull request quand ils sont
simples, sans enjeu métier, et couverts par des tests automatisés. Par exemple,
corriger la même formulation sur plusieurs formulaires. Dans ce cas, explique
dans la description comment tester chaque point séparément.

Dès qu’il y a du métier en jeu, on fait une pull request par sujet. Même chose
pour l’accessibilité, qui se teste à la main : avec dix corrections dans la
même pull request, la personne qui relit ne sait plus ce qu’elle a vérifié.

Une pull request de plusieurs milliers de lignes, personne ne peut la relire
correctement. Si la tienne en arrive là, il fallait sans doute découper plus
tôt.

## 3. Ce qu’on met dans une pull request

Dans la description :

- quelques lignes de contexte : de quoi il s’agit et pourquoi ;
- les choix techniques qui pourraient surprendre (pas besoin de raconter le
  diff) ;
- une partie « Comment tester » pour les développeurs qui relisent : la
  branche à lancer en local, les commandes utiles (seeds, migrations, tâches),
  les comptes de test, où aller, quoi faire, ce qu’on doit voir.

Si l’interface change, ajoute une capture d’écran ou une courte vidéo.

Ce « Comment tester » est écrit pour l’équipe technique. La PO a le sien, dans
le ticket Linear (voir la section 8).

## 4. Avant de demander une relecture

On se relit d’abord soi-même :

- relis ton diff sur GitHub, pas seulement dans ton éditeur, on y remarque
  d’autres choses ;
- teste dans le navigateur que tout fonctionne ;
- si tu as touché au front, lance l’audit d’accessibilité ;
- un assistant peut aider à repérer des oublis, si ça t’est utile.

Quand tu sors une pull request du mode brouillon, c’est que tu la considères
prête côté technique. Elle ne sera mergée qu’après la validation de la PO (voir
la section 8).

## 5. Comment se passe une relecture

On ne relit pas une pull request en brouillon. Tant qu’elle est en draft, on
laisse la personne travailler et on ne commente pas.

Quand elle sort du brouillon, préviens sur le salon Tchap de l’équipe
technique, en une phrase : de quoi il s’agit, et qui pourrait s’en charger.

Il n’y a pas de délai fixe pour relire. On s’organise selon l’urgence et la
charge du moment, et on en parle si ça coince.

On n’assigne personne d’office. La personne qui relit s’assigne elle-même sur
GitHub quand elle commence. Comme ça, on voit combien de temps une pull request
attend avant d’être prise.

Une fois la relecture finie, préviens directement la personne qui a écrit le
code.

On ne merge pas sa propre pull request, même quand la CI est verte.

## 6. Ce qu’on attend d’une relecture

Personne ne te reprochera un bug qui serait passé malgré la relecture. On te
demande en revanche d’avoir vraiment regardé.

Relire, c’est :

- lire le code et signaler ce qui te paraît bizarre ;
- tester la modification en suivant le « Comment tester » de la pull request ;
- signaler les effets de bord possibles, même en dehors de ce qui est annoncé.

L’accessibilité fait partie de la relecture, comme le reste. Ce n’est pas le
travail d’une seule personne ni une étape qu’on garde pour la fin.

Les questions d’architecture, c’est mieux d’en parler avant d’écrire le code.
Si elles arrivent pendant la relecture, on les traite quand même.

## 7. Trois types de remarques

Quand tu fais une remarque, dis de quel type elle est. Sinon, la personne en
face ne sait pas si elle doit corriger ou si elle peut choisir.

| Type | Ce que ça veut dire |
|---|---|
| **Bloquant** | La pull request ne peut pas être mergée tant que ce n’est pas corrigé. |
| **Non bloquant** | À corriger, mais ça peut attendre. Dans ce cas, on crée un ticket Linear, sinon ça ne sera jamais fait. |
| **Suggestion** | Une idée ou une question de goût. La personne qui a écrit le code décide. |

Dans tous les cas, avant de merger, on vérifie que le code fonctionne, que rien
n’est cassé côté métier ni côté design, et que l’accessibilité n’a pas reculé.

Et on essaie de laisser le code un peu plus propre qu’on l’a trouvé.

## 8. Le parcours d’un ticket

Les tickets sont rédigés par la PO avec un canevas commun. Chaque ticket
contient des règles de gestion (RG), des critères d’acceptation (CA) et, en bas,
deux listes à cocher : la DoR et la DoD.

### Avant de commencer : la DoR

La *Definition of Ready* dit si un ticket peut être pris. On ne démarre pas un
ticket tant qu’elle n’est pas cochée :

- les dépendances externes sont levées, ou au moins identifiées ;
- on sait pour qui on le fait, et pourquoi ;
- la valeur métier est claire ;
- le ticket est estimé ;
- les critères d’acceptation sont écrits et partagés ;
- les maquettes, règles de gestion et spécifications utiles sont disponibles ;
- les besoins d’accessibilité sont connus avant de coder.

S’il manque quelque chose, signale-le à la PO plutôt que de deviner.

### Pendant le développement : les critères d’acceptation

Les critères d’acceptation sont écrits sous la forme « Étant donné… Quand…
Alors… », et chacun renvoie aux règles de gestion qu’il vérifie. Ils servent de
base aux deux « Comment tester », celui de la pull request et celui du ticket.
Au fil de la recette, on note leur état directement dans le ticket (OK ou KO),
avec une capture si besoin.

### Les statuts dans Linear

Un ticket passe par ces statuts :

Triage → Backlog → Todo → In Progress → In Review → Review PO/UX → Done

- In Review : la pull request est sortie du brouillon et attend une relecture
  technique.
- Review PO/UX : la relecture technique est faite et approuvée. La PO (Natalia
  aujourd’hui) ou l’UX teste à son tour, sur une démo ou en suivant les
  critères d’acceptation.
- Done : la modification est en production.

On ne merge pas sans l’accord de la PO, donné à la fin de la review PO/UX. Une
pull request approuvée par un développeur n’est pas encore prête à être
mergée.

Si la PO ou l’UX demande des changements, le ticket repasse en In Progress.

### Préparer la review PO/UX

Avant de passer un ticket en Review PO/UX, on prépare le terrain pour que la
PO puisse tester seule, sans avoir à nous demander comment faire :

- déployer la branche sur staging, pour que la modification soit testable en
  conditions réelles ;
- écrire un « Comment tester » en commentaire du ticket Linear, pour quelqu’un
  qui n’est pas développeur : où aller, avec quel compte, quoi faire, ce qu’on
  doit voir ;
- préparer les données de test sur sandbox quand le cas n’existe pas déjà : un
  seed, une demande dans un état précis, une organisation particulière ;
- dire dans le commentaire Linear à quoi correspond chaque donnée créée. Par
  exemple : « demande n° 134 : habilitation validée avant la mise à jour ;
  n° 135 : demande soumise ; n° 136 : brouillon ». Sans ça, il faut deviner
  quelle demande illustre quel cas.

### Pour considérer un ticket terminé : la DoD

La *Definition of Done* liste ce qui doit être vrai pour passer un ticket en
Done :

- le code respecte les standards du projet ;
- les tests automatisés couvrent la modification et passent sur la CI ;
- les tests d’accessibilité de base sont passés ;
- le code a été relu par au moins une autre personne de l’équipe ;
- la dette technique n’a pas augmenté sans raison expliquée ;
- la PO ou l’UX a vu une démo ou validé les critères d’acceptation ;
- la modification est déployée en production ;
- la documentation est à jour.

### Les demandes externes

Depuis août 2026, toute demande qui arrive de l’extérieur (fournisseur de
données, partenaire, support) passe par le formulaire « Demande externe » de
Linear. Si quelqu’un te sollicite directement, par mail ou sur Tchap,
redirige-le vers ce formulaire ou crée la demande pour lui : c’est ce qui
permet de mesurer la charge réelle de l’équipe.

## 9. Ce qu’il reste à décider

On n’a pas encore tranché ces sujets. On complétera ce document au fur et à
mesure :

- les pull requests empilées (stacked PR) : est-ce qu’on en a besoin, et avec
  quel outil ;
- la recette : qui déploie sur staging et quand, quand plusieurs branches
  attendent en même temps ;
- le support : un roulement chaque semaine, et le lien avec le support de
  premier niveau.
