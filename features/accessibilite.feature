# language: fr
Fonctionnalité: Accessibilité
  En tant qu'utilisateur avec des besoins d'accessibilité
  Je veux pouvoir naviguer facilement sur le site
  Afin d'utiliser toutes les fonctionnalités du site de façon équitable

  @public
  Scénario: Les liens d'évitement fonctionnent correctement sur la page d'accueil
    Sachant que je me rends sur la page d'accueil
    Alors je dois voir des liens d'évitement
    Et le lien d'évitement "Bienvenue sur DataPass" doit mener à l'élément "#content"
    Et le lien d'évitement "Menu" doit mener à l'élément "#header"
    Et le lien d'évitement "Pied de page" doit mener à l'élément "#footer"

  @demandeur
  Scénario: Les liens d'évitement fonctionnent correctement sur la page tableau de bord
    Sachant que je suis un demandeur
    Et que j'ai 1 demande d'habilitation "API Entreprise" sujet à modification
    Et que j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et que j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et que j'ai 1 demande d'habilitation "API Entreprise" validée
    Et que je me connecte
    Et que je vais sur la page tableau de bord
    Alors je dois voir des liens d'évitement
    Et le lien d'évitement "Aller aux demandes" doit mener à l'élément "#tab-demandes"
    Et le lien d'évitement "Aller aux habilitations" doit mener à l'élément "#tab-habilitations"
    Et le lien d'évitement "Menu" doit mener à l'élément "#header"
    Et le lien d'évitement "Pied de page" doit mener à l'élément "#footer"

  @demandeur
  Scénario: Les liens d'évitement fonctionnent correctement sur la page de nouvelle demande d'habilitation
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que je démarre une nouvelle demande d'habilitation "API Entreprise"
    Alors je dois voir des liens d'évitement
    Et le lien d'évitement "Aller au contenu" doit mener à l'élément "#content"
    Et le lien d'évitement "Menu" doit mener à l'élément "#header"
    Et le lien d'évitement "Pied de page" doit mener à l'élément "#footer"

  @instructeur
  Scénario: Les liens d'évitement fonctionnent correctement sur la page d'instruction
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Et que je vais sur la page instruction
    Alors je dois voir des liens d'évitement
    Et le lien d'évitement "Filtres de recherche" doit mener à l'élément "#authorization_request_search"
    Et le lien d'évitement "Tableau des demandes" doit mener à l'élément "#authorization_requests_table"
    Et le lien d'évitement "Menu" doit mener à l'élément "#header"
    Et le lien d'évitement "Pied de page" doit mener à l'élément "#footer"
