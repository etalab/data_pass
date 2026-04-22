# language: fr

Fonctionnalité: Développeurs: consultation des tutoriels

  Scénario: Je peux voir l'index des tutoriels sans être connecté
    Quand je me rends sur le chemin "/developpeurs/tutoriels"
    Alors la page contient "Tutoriels développeurs"
    Et il y a un lien vers "/developpeurs/tutoriels/lecture"
    Et il y a un lien vers "/developpeurs/tutoriels/ecriture"
    Et il y a un lien vers "/developpeurs/tutoriels/webhooks"

  Scénario: Je peux consulter le tutoriel lecture
    Quand je me rends sur le chemin "/developpeurs/tutoriels/lecture"
    Alors la page contient "Tutoriel : exploiter l'API DataPass en lecture"
    Et la page contient "read_authorizations"

  Scénario: Je peux consulter le tutoriel écriture
    Quand je me rends sur le chemin "/developpeurs/tutoriels/ecriture"
    Alors la page contient "Tutoriel : exploiter l'API DataPass en écriture"
    Et la page contient "write_authorizations"

  Scénario: Je peux consulter le tutoriel webhooks
    Quand je me rends sur le chemin "/developpeurs/tutoriels/webhooks"
    Alors la page contient "Tutoriel : suivre les demandes via webhooks"
    Et la page contient "X-Hub-Signature-256"
