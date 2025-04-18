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

environnement_patterns = [
    [r'-sandbox$', 'Sandbox'],
    [r'-production$', 'Production'],
    [r'-editeur$', 'Unique'],
]

def match_environnement(form_uid):
    for pattern, value in environnement_patterns:
        if re.search(pattern, form_uid):
            return value
    return 'Environnement non trouvé'

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



# Missing values that aren't covered by patterns yet:
# - 'migration_api_particulier': 'Migration SVAIR',
# - 'eligibilite_lep': 'Éligibilité LEP',
# - 'quotient_familial': 'Calcul du quotient familial',
