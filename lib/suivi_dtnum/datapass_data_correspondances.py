import re

api_names = {
"AuthorizationRequest::APICprProAdelie":"CPR PRO",
"AuthorizationRequest::APIEContacts":"E-Contacts",
"AuthorizationRequest::APIENSUDocuments":"Ensu documents",
"AuthorizationRequest::APIEPro":"E-PRO",
"AuthorizationRequest::APIFicoba":"Ficoba",
"AuthorizationRequest::APIHermes":"Hermès",
"AuthorizationRequest::APIImpotParticulier":"Impôt particulier",
"AuthorizationRequest::APIINFINOE":"Infinoe",
"AuthorizationRequest::APIMire":"Mire",
"AuthorizationRequest::APIOcfi":"OCFI",
"AuthorizationRequest::APIOpale":"Opale",
"AuthorizationRequest::APIR2P":"R2P",
"AuthorizationRequest::APIRial":"RIAL",
"AuthorizationRequest::APIRobf":"ROBF",
"AuthorizationRequest::APISFiP":"SFiP",
"AuthorizationRequest::APISatelit":"Satelit",

"AuthorizationRequest::APICprProAdelieSandbox":"CPR PRO",
"AuthorizationRequest::APIEContactsSandbox":"E-Contacts",
"AuthorizationRequest::APIENSUDocumentsSandbox":"Ensu documents",
"AuthorizationRequest::APIEProSandbox":"E-PRO",
"AuthorizationRequest::APIFicobaSandbox":"Ficoba",
"AuthorizationRequest::APIHermesSandbox":"Hermès",
"AuthorizationRequest::APIImpotParticulierSandbox":"Impôt particulier",
"AuthorizationRequest::APIINFINOESandbox":"Infinoe",
"AuthorizationRequest::APIMireSandbox":"Mire",
"AuthorizationRequest::APIOcfiSandbox":"OCFI",
"AuthorizationRequest::APIOpaleSandbox":"Opale",
"AuthorizationRequest::APIR2PSandbox":"R2P",
"AuthorizationRequest::APIRialSandbox":"RIAL",
"AuthorizationRequest::APIRobfSandbox":"ROBF",
"AuthorizationRequest::APISFiPSandbox":"SFiP",
"AuthorizationRequest::APISatelitSandbox":"Satelit"
}

def match_api_name(api_name):
    return api_names.get(api_name, "API inconnue")


def match_environnement(form_uid, demande_type):
    if re.search(r'-editeur$', form_uid):
        return 'Unique'
    elif re.search(r'Sandbox$', demande_type):
        return "Sandbox"
    else:
        return "Production"

# Regex pattern-based matching for use cases
cas_dusage_patterns = [
    # CITP patterns
    (r'activites-periscolaires', 'CITP - activités périscolaires'),
    (r'aides-sociales-facultatives', 'CITP - aides sociales facultatives'),
    (r'cantine-scolaire', 'CITP - cantine scolaire'),
    (r'carte-transport', 'CITP - carte de transport'),
    (r'place-creche', 'CITP - place en crèche'),
    (r'stationnement-residentiel', 'CITP - stationnement résidentiel'),
    
    # Récupération de données fiscales
    (r'api-r2p-(sandbox|production|editeur)$', 'Récupération de données fiscales'),
    
    # Ordonnateur
    (r'api-r2p-ordonnateur', 'Ordonnateur - fiabilisation des bases tiers (collectivités)'),
    
    # Envoi automatisé des écritures
    (r'api-infinoe-envoi-automatise-ecritures', 'Envoi automatisé des écritures'),
]

def match_cas_dusage(form_uid):
    # Try to find a match in the patterns
    for pattern, value in cas_dusage_patterns:
        if re.search(pattern, form_uid):
            return value

    # If no match found, return default
    return 'Saisie libre'

statut_correspondances = {
    # Status of demandes
    'draft': 'Brouillon',
    'submitted':'Traitement en cours par la DGFiP',
    'changes_requested':'Modifications demandées au partenaire',
    'validated':'Accepté',
    'refused':'Refusé',
    'archived':'Supprimé',
    # Status of habilitations
    'active': 'Accepté',
    'obsolete': 'Accepté (obsolète)',
    'revoked': 'Révoqué'
}

def match_statut(statut):
    return statut_correspondances.get(statut, "Statut inconnu")