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

api_environnments = {
"AuthorizationRequest::APICprProAdelie":"Production ",
"AuthorizationRequest::APIEContacts":"Production",
"AuthorizationRequest::APIENSUDocuments":"Production",
"AuthorizationRequest::APIEPro":"Production",
"AuthorizationRequest::APIFicoba":"Production",
"AuthorizationRequest::APIHermes":"Production",
"AuthorizationRequest::APIImpotParticulier":"Production",
"AuthorizationRequest::APIINFINOE":"Production",
"AuthorizationRequest::APIMire":"Production",
"AuthorizationRequest::APIOcfi":"Production",
"AuthorizationRequest::APIOpale":"Production",
"AuthorizationRequest::APIR2P":"Production",
"AuthorizationRequest::APIRial":"Production",
"AuthorizationRequest::APIRobf":"Production",
"AuthorizationRequest::APISFiP":"Production",
"AuthorizationRequest::APISatelit":"Production",

"AuthorizationRequest::APICprProAdelieSandbox":"Sandbox",
"AuthorizationRequest::APIEContactsSandbox":"Sandbox",
"AuthorizationRequest::APIENSUDocumentsSandbox":"Sandbox",
"AuthorizationRequest::APIEProSandbox":"Sandbox",
"AuthorizationRequest::APIFicobaSandbox":"Sandbox",
"AuthorizationRequest::APIHermesSandbox":"Sandbox",
"AuthorizationRequest::APIImpotParticulierSandbox":"Sandbox",
"AuthorizationRequest::APIINFINOESandbox":"Sandbox",
"AuthorizationRequest::APIMireSandbox":"Sandbox",
"AuthorizationRequest::APIOcfiSandbox":"Sandbox",
"AuthorizationRequest::APIOpaleSandbox":"Sandbox",
"AuthorizationRequest::APIR2PSandbox":"Sandbox",
"AuthorizationRequest::APIRialSandbox":"Sandbox",
"AuthorizationRequest::APIRobfSandbox":"Sandbox",
"AuthorizationRequest::APISFiPSandbox":"Sandbox",
"AuthorizationRequest::APISatelitSandbox":"Sandbox"
}

# Regex pattern-based matching for use cases
cas_dusage_patterns = [
    # CITP patterns
    (r'activites-periscolaires', 'CITP - activités périscolaires'),
    (r'aides-sociales-facultatives', 'CITP - aides sociales facultatives'),
    (r'apicantine-scolaire', 'CITP - cantine scolaire'),
    (r'apicarte-transport', 'CITP - carte de transport'),
    (r'apiplace-creche', 'CITP - place en crèche'),
    (r'apistationnement-residentiel', 'CITP - stationnement résidentiel'),
    
    # Récupération de données fiscales
    (r'api-impot-particulier$', 'Récupération de données fiscales'),
    
    # Ordonnateur
    (r'api-r2p-ordonnateur', 'Ordonnateur - fiabilisation des bases tiers (collectivités)'),
    
    # Envoi automatisé des écritures
    (r'api-infinoe-envoi-automatise-ecritures', 'Envoi automatisé des écritures'),
    
    # Default case (when no specific pattern matches)
    (r'.*', 'Saisie libre')
]

def match_cas_dusage(key):
    # Try to find a match in the patterns
    for pattern, value in cas_dusage_patterns:
        if re.match(pattern, key):
            return value
    
    # If no match found, return default
    return 'Saisie libre'



# Missing values that aren't covered by patterns yet:
# - 'migration_api_particulier': 'Migration SVAIR',
# - 'eligibilite_lep': 'Éligibilité LEP',
# - 'quotient_familial': 'Calcul du quotient familial',
