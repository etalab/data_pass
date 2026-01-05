import requests

# Need an admin API key here
API_KEY = "fill me"

def update_dataservice(dataservice_id: str, dataservice_slug: str, new_url: str):
    print('\nUpdating', dataservice_id, dataservice_slug)
    url = f"https://www.data.gouv.fr/api/1/dataservices/{dataservice_id}/"
    headers = {
      'Content-Type': 'application/json',
      'X-API-KEY': API_KEY
    }

    # Do we need to provide more fields for the patch to work?
    body = {
      "authorization_request_url": new_url
    }
    response = requests.patch(url, json=body, headers=headers)

    if response.status_code == 200:
        print('updated', dataservice_id, dataservice_slug)
    else:
        print('error updating', dataservice_id, dataservice_slug)
        print(response.status_code, response.text)

    return response

data = [
  {
    "id": "672cf644f8b5d52b76263392",
    "title": "API SI Amiante",
    "slug": "api-si-amiante",
    "access_url": "https://api.gouv.fr/les-api/api-si-amiante/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-si-amiante/",
    "new_datapass_access_url": "mailto:si-amiante@sante.gouv.fr",
    "organization_name": "Ministère des Solidarités et de la Santé"
  },
  {
    "id": "672cf646403bf419125795dc",
    "title": "API Ma Sécurité",
    "slug": "api-ma-securite",
    "access_url": "https://api.gouv.fr/les-api/api-ma-securite/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-ma-securite/",
    "new_datapass_access_url": "mailto:masecuritelappli@gendarmerie.interieur.gouv.fr",
    "organization_name": "Ministère de l'intérieur"
  },
  {
    "id": "672cf647fcc8065be6e66f51",
    "title": "API Liste des paiements",
    "slug": "api-liste-des-paiements",
    "access_url": "https://api.gouv.fr/les-api/api-indemnisation-pole-emploi/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-liste-des-paiements/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/api-indemnisation-pole-emploi",
    "organization_name": "France Travail"
  },
  {
    "id": "672cf655a474f2d73502b5ce",
    "title": "API données foncières",
    "slug": "api-donnees-foncieres",
    "access_url": "https://api.gouv.fr/les-api/api-donnees-foncieres/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-donnees-foncieres/",
    "new_datapass_access_url": "https://consultdf.cerema.fr/consultdf/",
    "organization_name": "Cerema"
  },
  {
    "id": "672cf657f8b5d52b76263395",
    "title": "API Engagement",
    "slug": "api-engagement",
    "access_url": "https://api.gouv.fr/les-api/api-engagement/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-engagement/",
    "new_datapass_access_url": "https://doc.api-engagement.beta.gouv.fr/getting-started/create-your-account",
    "organization_name": "Ministères de l'Éducation nationale, Sports et Jeunesse"
  },
  {
    "id": "672cf65fc3488a0c533f7090",
    "title": "API Statut Etudiant - écriture",
    "slug": "api-statut-etudiant-ecriture",
    "access_url": "https://api.gouv.fr/les-api/api-statut-etudiant-ecriture/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-statut-etudiant-ecriture/",
    "new_datapass_access_url": "https://statutetudiant.esr.gouv.fr/pages/etablissement",
    "organization_name": "Ministère de l'Enseignement supérieur, de la Recherche et de l'Espace"
  },
  {
    "id": "672cf66df89f31dae828f6d8",
    "title": "API Data.Subvention",
    "slug": "api-data-subvention",
    "access_url": "https://api.gouv.fr/les-api/api-data-subvention/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-data-subvention/",
    "new_datapass_access_url": "mailto:contact@datasubvention.beta.gouv.fr",
    "organization_name": "Direction interministérielle du numérique"
  },
  {
    "id": "672cf671a47b8d4c15d13d5c",
    "title": "API Déclaration préalable à l'embauche",
    "slug": "api-declaration-prealable-a-lembauche",
    "access_url": "https://api.gouv.fr/les-api/api-declaration-embauche/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-declaration-prealable-a-lembauche/",
    "new_datapass_access_url": "mailto:api-dpae@acoss.fr",
    "organization_name": "Unions de Recouvrement des cotisations de Sécurité Sociale et d'Allocations Familiales"
  },
  {
    "id": "672cf6740666cac46925be2f",
    "title": "API Base nationale des défibrillateurs",
    "slug": "api-base-nationale-des-defibrillateurs",
    "access_url": "https://api.gouv.fr/les-api/api-defibrillateurs/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-base-nationale-des-defibrillateurs/",
    "new_datapass_access_url": "mailto:contact@geodae.sante.gouv.fr",
    "organization_name": "Ministère des Solidarités et de la Santé"
  },
  {
    "id": "672cf680a47b8d4c15d13d5e",
    "title": "API Sesali",
    "slug": "api-sesali",
    "access_url": "https://api.gouv.fr/les-api/api-sesali/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-sesali/",
    "new_datapass_access_url": "mailto:ans-europe@esante.gouv.fr",
    "organization_name": "Agence du Numérique en Santé"
  },
  {
    "id": "672cf695a316ad54c9a7f199",
    "title": "API Chorus Pro",
    "slug": "api-chorus-pro",
    "access_url": "https://api.gouv.fr/les-api/chorus-pro/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-chorus-pro/",
    "new_datapass_access_url": "https://piste.gouv.fr/en/api-catalog-sandbox",
    "organization_name": "Agence pour l'Informatique Financière de l'Etat"
  },
  {
    "id": "672cf699c3488a0c533f7097",
    "title": "API QuiForme",
    "slug": "api-quiforme",
    "access_url": "https://api.gouv.fr/les-api/api_quiforme/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-quiforme/",
    "new_datapass_access_url": "mailto:quiforme@intercariforef.org",
    "organization_name": "Réseau des Carif-Oref"
  },
  {
    "id": "672cf6a36d09c75cace6a628",
    "title": "API Tracabilité des déchets dangereux - Trackdéchets",
    "slug": "api-tracabilite-des-dechets-dangereux-trackdechets",
    "access_url": "https://api.gouv.fr/les-api/api-trackdechets/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-tracabilite-des-dechets-dangereux-trackdechets/",
    "new_datapass_access_url": "https://app.trackdechets.beta.gouv.fr/signup",
    "organization_name": "Ministère de la Transition écologique"
  },
  {
    "id": "672cf6a86d09c75cace6a629",
    "title": "API INES",
    "slug": "api-ines",
    "access_url": "https://api.gouv.fr/les-api/api-ines/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-ines/",
    "new_datapass_access_url": "mailto:projet.ines@enseignementsup.gouv.fr",
    "organization_name": "Ministère de l'Enseignement supérieur, de la Recherche et de l'Espace"
  },
  {
    "id": "672cf6a8b93233d94703aadb",
    "title": "API Ma Cantine",
    "slug": "api-ma-cantine",
    "access_url": "https://api.gouv.fr/les-api/api-ma-cantine/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-ma-cantine/",
    "new_datapass_access_url": "https://ma-cantine-demo.cleverapps.io/developpement-et-apis/",
    "organization_name": "Direction interministérielle du numérique"
  },
  {
    "id": "672cf71ed2525afd25d1e4a3",
    "title": "API Transparence-Santé (Déclarations Entreprises)",
    "slug": "api-transparence-sante-declarations-entreprises",
    "access_url": "https://api.gouv.fr/les-api/api-transparence-sante/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-transparence-sante-declarations-entreprises/",
    "new_datapass_access_url": "mailto:transparence-sante-support@sante.gouv.fr",
    "organization_name": "Ministère des Solidarités et de la Santé"
  },
  {
    "id": "672cf985506e25cb5c5086cc",
    "title": "API Service National",
    "slug": "api-service-national",
    "access_url": "https://api.gouv.fr/les-api/api-particulier/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-service-national/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/api-particulier",
    "organization_name": "Ministère des Armées"
  },
  {
    "id": "672cfc44fa6cdbd0efe62e62",
    "title": "API Document unique de marché européen (Dume)",
    "slug": "api-document-unique-de-marche-europeen-dume",
    "access_url": "https://api.gouv.fr/les-api/api-dume/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-document-unique-de-marche-europeen-dume/",
    "new_datapass_access_url": "https://developer.aife.economie.gouv.fr/",
    "organization_name": "Agence pour l'Informatique Financière de l'Etat"
  },
  {
    "id": "672cfc48f92a8fae20ccf3eb",
    "title": "API Statut demandeur d'emploi",
    "slug": "api-statut-demandeur-demploi",
    "access_url": "https://api.gouv.fr/les-api/api-particulier/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-statut-demandeur-demploi/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/api-particulier",
    "organization_name": "France Travail"
  },
  {
    "id": "672cfc5bc21305d715be7f34",
    "title": "API Registre des Bénéficiaires Effectifs (RBE)",
    "slug": "api-registre-des-beneficiaires-effectifs-rbe",
    "access_url": "https://api.gouv.fr/les-api/api-rbe/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-registre-des-beneficiaires-effectifs-rbe/",
    "new_datapass_access_url": "https://api.gouv.fr/resources/formulaire_rbe.pdf",
    "organization_name": "Institut national de la propriété industrielle (INPI)"
  },
  {
    "id": "672cfc5cc1fa613534d1d73a",
    "title": "API GRDF ADICT",
    "slug": "api-grdf-adict",
    "access_url": "https://api.gouv.fr/les-api/api-grdf-adict/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-grdf-adict/",
    "new_datapass_access_url": "https://sites.grdf.fr/web/portail-api-grdf-adict/je-souhaite-souscrire-aux-services-grdf-adict",
    "organization_name": "GRDF"
  }
]

# Loop over the content and print titles
for item in data:
    update_dataservice(item['id'], item['slug'], item['new_datapass_access_url'])

print('\nAll done.\n')