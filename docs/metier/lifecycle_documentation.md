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
  D -->G(Délivrance d'une habilitation)
  E -->|le demandeur soumet des modifications|B
  C -->|l'instructeur valide la demande| D[state:validated]
  
  class A,B,D,E,F stateNodes;
```

Une demande peut être archivée par l'instructeur ou le demandeur (si elle n'a aucune habilitation active), dans ce cas le status devient <code>archived</code>, et elle ne sera plus visible dans DataPass.


## Cas d'une demande de mise à jour (réouverture)

Le demandeur peut demander la mise à jour d'une habilitation active : sa demande repasse alors en instruction pour apporter des changements à l'habilitation qui lui a été délivrée. Dans le code, ce cycle s'appelle `reopening` (un paramètre booléen porte cet état) ; dans les textes affichés, on parle de « demande de mise à jour ».

Voici le cycle de vie d'une demande de mise à jour.


```mermaid
  flowchart TD
  classDef stateNodes fill:#8ab4ff;
  
  0(La demande a été validée : une habilitation active existe déjà) --> A0[state:validated reopening:false]
  A0 -->|le demandeur demande une mise à jour de l'habilitation| A[state:draft reopening:true]
  A -->|le demandeur soumet sa demande| B[state:submitted reopening:true]
  B --> C{Instruction de la demande}
  C -->|l'instructeur refuse la demande de mise à jour| F(la demande retourne à l'état validé, l'habilitation en cours reste active)
  F -->A0
  C -->|l'instructeur demande des modifications| E[state:changes_requested reopening:true]
  D -->G(Délivrance d'une nouvelle habilitation, l'ancienne devient obsolète)
  E -->|le demandeur soumet des modifications|B
  C -->|l'instructeur valide la demande de mise à jour| D[state:validated reopening:false]

  class A0,A,B,D,E stateNodes;
```

Après la délivrance de la nouvelle habilitation, la demande aura donc donné lieu à 2 habilitations.

# Status d'une Habilitation

Une habilitation commence son existence `state:active`. Si une nouvelle habilitation est délivrée à la suite d'une demande de mise à jour, l'ancienne habilitation devient `state:obsolete`.

Une habilitation peut aussi être révoquée par un instructeur, devenant donc `state:revoked`.

```mermaid
  flowchart TD
  classDef stateNodes fill:#8ab4ff;

  0(L'habilitation est délivrée) -->A[state:active]
  A --> |Délivrance d'une nouvelle habilitation| B[state: obsolete]
  A --> |révocation de l'habilitation par un instructeur| C[state:revoked]

  class A,B,C stateNodes;
```

