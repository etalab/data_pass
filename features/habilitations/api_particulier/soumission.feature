# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Particulier
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation libre valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Demande libre"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
    * je clique sur "Suivant"

    * je coche "Quotient familial CAF & MSA"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Aiga valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "iNoé, Tarification services municipaux / Portail Famille" de l'éditeur "Aiga"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Coexya valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Coexya, solution portail tarification sociale et solidaire ICAR" de l'éditeur "Coexya"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je renseigne les infos concernant les données personnelles

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Abelium Collectivités valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Domino web 2.0, Tarification services municipaux / Portail Famille" de l'éditeur "Abelium Collectivités"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je renseigne les infos concernant les données personnelles

    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Agora Plus valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Agora Famille Premium, Tarification services municipaux / Portail Famille" de l'éditeur "Agora Plus"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Amiciel valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Malice, Tarification services municipaux / Portail Famille" de l'éditeur "Amiciel"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je renseigne les infos concernant les données personnelles

    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Arpège Concerto valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Concerto, Tarification services municipaux / Portail Famille" de l'éditeur "Arpège"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je renseigne les infos concernant les données personnelles
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Berger-Levrault valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "BL Enfance, Tarification services municipaux / Portail Famille" de l'éditeur "Berger-Levrault"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Jdéalise (Cantine de France) valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Cantines-de-France, Tarification services municipaux / Portail Famille" de l'éditeur "Jdéalise (Cantine de France)"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je renseigne les infos concernant les données personnelles

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Arche MC2 valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Arche MC2, Dématérialisation de l'instruction des dossiers dans un CCAS/CIAS" de l'éditeur "Arche MC2"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Arpège CCAS valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Dématérialisation de l'instruction des dossiers dans un CCAS" de l'éditeur "Arpège"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Agence Française d'Informatique (AFI) valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Mélissandre, Dématérialisation de l'instruction des dossiers dans un CCAS" de l'éditeur "Agence Française d'Informatique (AFI)"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Mushroom Software valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "City Family, Tarification services municipaux / Portail Famille" de l'éditeur "Mushroom Software"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Ciril GROUP valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Civil Enfance, Tarification services municipaux / Portail Famille" de l'éditeur "Ciril GROUP"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Cosoluce valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Fluo, Tarification services municipaux / Portail Famille" de l'éditeur "Cosoluce"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je renseigne les infos concernant les données personnelles

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation DOCAPOSTE valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Tarification services municipaux / Portail Famille" de l'éditeur "DOCAPOSTE"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Entrouvert valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Publik Famille, Tarification services municipaux / Portail Famille" de l'éditeur "Entrouvert"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je renseigne les infos concernant les données personnelles
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation JVS-Mairistem valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Parascol, Tarification services municipaux / Portail Famille" de l'éditeur "JVS-Mairistem"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Nord France Informatique valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Tarification services municipaux / Portail Famille" de l'éditeur "Nord France Informatique"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Odyssée Informatique valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Pandore, Tarification services municipaux / Portail Famille" de l'éditeur "Odyssée Informatique"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Qiis valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "eTicket, Tarification services municipaux / Portail Famille" de l'éditeur "Qiis"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation SIGEC valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Maelis Portail, Tarification services municipaux / Portail Famille" de l'éditeur "SIGEC"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je renseigne les infos concernant les données personnelles

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Teamnet valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Axel, Tarification services municipaux / Portail Famille" de l'éditeur "Teamnet"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Technocarte valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "ILE, Tarification service enfance" de l'éditeur "Technocarte"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation Waigeo valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "MyPerischool, Tarification services municipaux / Portail Famille" de l'éditeur "Waigeo"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation 3D Ouest valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "3D Ouest, Tarification services municipaux / Portail Famille" de l'éditeur "3D Ouest"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


