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
    "id": "672cf99d5e8f9949017928ae",
    "title": "API CaptchEtat",
    "slug": "api-captchetat",
    "access_url": "https://api.gouv.fr/les-api/api-captchetat/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-captchetat/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-captchetat/nouveau",
    "organization_name": "Agence pour l'Informatique Financière de l'Etat"
  },
  {
    "id": "672cf6605e554cca4a916025",
    "title": "API de droits à l'Assurance Maladie",
    "slug": "api-de-droits-a-lassurance-maladie",
    "access_url": "https://api.gouv.fr/les-api/api_ameli_droits_cnam/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-de-droits-a-lassurance-maladie/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-droits-cnam/nouveau",
    "organization_name": "Caisse nationale de l'Assurance Maladie"
  },
  {
    "id": "672cf6a36d09c75cace6a627",
    "title": "API Entreprise",
    "slug": "api-entreprise",
    "access_url": "https://api.gouv.fr/les-api/api-entreprise/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-entreprise/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-entreprise/nouveau",
    "organization_name": "Direction interministérielle du numérique"
  },
  {
    "id": "672dcfd4fb13e93799d97e68",
    "title": "API Fichier des Comptes Bancaires et Assimilés (FICOBA)",
    "slug": "api-fichier-des-comptes-bancaires-et-assimiles-ficoba",
    "access_url": "https://api.gouv.fr/les-api/api_comptes_bancaires_ficoba/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-fichier-des-comptes-bancaires-et-assimiles-ficoba/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-ficoba/nouveau",
    "organization_name": "Ministère de l'Économie, des Finances et de l'Industrie"
  },
  {
    "id": "672cf984cbc098058850c092",
    "title": "API Impôt particulier",
    "slug": "api-impot-particulier",
    "access_url": "https://api.gouv.fr/les-api/impot-particulier/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-impot-particulier/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-impot-particulier/nouveau",
    "organization_name": "Ministère de l'Économie, des Finances et de l'Industrie"
  },
  {
    "id": "672dcf037d26da92ddef47f7",
    "title": "API IMPRIM'FIP",
    "slug": "api-imprimfip",
    "access_url": "https://api.gouv.fr/les-api/api-imprimfip/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-imprimfip/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-imprimfip-sandbox/nouveau",
    "organization_name": "Ministère de l'Économie, des Finances et de l'Industrie"
  },
  {
    "id": "672cf6776d09c75cace6a624",
    "title": "API Indemnités Journalières de la CNAM",
    "slug": "api-indemnites-journalieres-de-la-cnam",
    "access_url": "https://api.gouv.fr/les-api/api-indemnites-journalieres-cnam/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-indemnites-journalieres-de-la-cnam/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-indemnites-journalieres-cnam/nouveau",
    "organization_name": "Caisse nationale de l'Assurance Maladie"
  },
  {
    "id": "672cf650ab1def0132e0fc7c",
    "title": "API Mobilic",
    "slug": "api-mobilic",
    "access_url": "https://api.gouv.fr/les-api/api-mobilic/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-mobilic/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-mobilic/nouveau",
    "organization_name": "Ministère de la Transition écologique"
  },
  {
    "id": "672cf66c6d09c75cace6a623",
    "title": "API Pro Santé Connect",
    "slug": "api-pro-sante-connect",
    "access_url": "https://api.gouv.fr/les-api/api-pro-sante-connect/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-pro-sante-connect/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-pro-sante-connect/nouveau",
    "organization_name": "Agence du Numérique en Santé"
  },
  {
    "id": "6792183de0b7b74fe06e55dc",
    "title": "API scolarité de l'élève",
    "slug": "api-scolarite-de-leleve-1",
    "access_url": "https://api.gouv.fr/les-api/api-scolarite-ministere-education-nationale/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-scolarite-de-leleve-1/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-scolarite/nouveau",
    "organization_name": "Ministères de l'Éducation nationale, Sports et Jeunesse"
  },
  {
    "id": "672cf67aa37a79f6ff3e324e",
    "title": "API Recherche des personnes physiques (R2P)",
    "slug": "api-recherche-des-personnes-physiques-r2p",
    "access_url": "https://api.gouv.fr/les-api/api-sfip/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-recherche-des-personnes-physiques-r2p/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api-sfip/nouveau",
    "organization_name": "Ministère de l'Économie, des Finances et de l'Industrie"
  },
  {
    "id": "672cf6944a683b4496789e92",
    "title": "API FranceConnect",
    "slug": "api-franceconnect",
    "access_url": "https://api.gouv.fr/les-api/franceconnect/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-franceconnect/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/france-connect/nouveau",
    "organization_name": "Direction interministérielle du numérique"
  },
  {
    "id": "672cf69b65f131fae343442b",
    "title": "le.taxi",
    "slug": "le-taxi",
    "access_url": "https://api.gouv.fr/les-api/le-taxi/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/le-taxi/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/le-taxi/nouveau",
    "organization_name": "Direction interministérielle du numérique"
  },
  {
    "id": "672cf66ef8b5d52b76263398",
    "title": "API Service Finances Publiques (SFiP)",
    "slug": "api-service-finances-publiques-sfip",
    "access_url": "https://api.gouv.fr/les-api/api-sfip/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/api-service-finances-publiques-sfip/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api_sfip/nouveau",
    "organization_name": "Ministère de l'Économie, des Finances et de l'Industrie"
  },
  {
    "id": "67acdc5b2442665160389f62",
    "title": "RIAL (Répertoire Inter-Administratif des Locaux)",
    "slug": "rial-repertoire-inter-administratif-des-locaux",
    "access_url": "https://api.gouv.fr/les-api/api_rial/demande-acces",
    "url": "https://www.data.gouv.fr/dataservices/rial-repertoire-inter-administratif-des-locaux/",
    "new_datapass_access_url": "https://datapass.api.gouv.fr/demandes/api_rial_sandbox/nouveau",
    "organization_name": "Ministère de l'Économie, des Finances et de l'Industrie"
  },
]

# Loop over the content and print titles
for item in data:
    update_dataservice(item['id'], item['slug'], item['new_datapass_access_url'])

print('\nAll done.\n')