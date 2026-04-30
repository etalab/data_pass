# Cycle de vie d'une Demande

## Cas d'une demande initiale

Voici le cycle de vie basique d'une demande.

```mermaid
  flowchart TD
  classDef stateNodes fill:#8ab4ff;
  
  0(Création d'une demande) --> A[state:draft]
  A -->|le demandeur soumet sa demande| B[state:submitted]
  B --> C{Instruction de la demande}
  C -->|l'instructeur refuse la demande| F[state:refused]
  C -->|l'instructeur demande des modifications| E[state:changes_requested]
  D -->G(Génération  d'une habilitation)
  E -->|le demandeur soumet des modifications|B
  C -->|l'instructeur valide la demande| D[state:validated]
  
  class A,B,D,E,F stateNodes;
```

Une demande peut être archivée par l'instructeur ou le demandeur (si elle n'a aucune habilitation active), dans ce cas le status devient <code>archived</code>, et elle ne sera plus visible dans DataPass.


## Cas d'une réouverture

Une demande est dite en "réouverture" lorsqu'elle a déjà une habilitation, et que le demandeur la soumet à nouveau pour apporter des changements à l'habilitation qui lui a été délivrée.

Un paramètre booléen `reopening` représente l'état de réouverture d'une demande.

Voici le cycle de vie d'une demande lorsqu'elle est réouverte.


```mermaid
  flowchart TD
  classDef stateNodes fill:#8ab4ff;
  
  0(Une demande validée existe déjà, avec une habilitation) --> A0[state:validated reopening:false]
  A0 -->|le demandeur réouvre la demande| A[state:draft reopening:true]
  A -->|le demandeur soumet sa demande| B[state:submitted reopening:true]
  B --> C{Instruction de la demande}
  C -->|l'instructeur refuse la demande de réouverture| F(la demande retourne à l'état initial)
  F -->A0
  C -->|l'instructeur demande des modifications| E[state:changes_requested reopening:true]
  D -->G(Génération d'une nouvelle habilitation)
  E -->|le demandeur soumet des modifications|B
  C -->|l'instructeur valide la demande de réouverture| D[state:validated reopening:false]

  class A0,A,B,D,E stateNodes;
```

Après la génération d'une nouvelle habilitation, la demande aura donc été en tout à l'origine de 2 habilitations.

# Status d'une Habilitation

Une habilitation commence son existence `state:active`. Si une nouvelle habilitation est générée suite à une réouverture de sa demande, l'ancienne habilitation devient `state:obsolete`.

Une habilitation peut aussi être révoquée par un instructeur, devenant donc `state:revoked`.

```mermaid
  flowchart TD
  classDef stateNodes fill:#8ab4ff;

  0(L'habilitation est générée) -->A[state:active]
  A --> |Génération d'une nouvelle habilitation| B[state: obsolete]
  A --> |révocation de l'habilitation par un instructeur| C[state:revoked]

  class A,B,C stateNodes;
```

