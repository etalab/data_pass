import json
import sys
import os
import pandas as pd
from datetime import datetime
from datapass_api_client import DataPassApiClient

# Define paths relative to the script's directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ORIGINAL_FILE_PATH = os.path.join(SCRIPT_DIR, "sources", "Fichier de suivi DTNUM 1404 with v2 ids.ods")
MATCHED_IDS_PATH = os.path.join(SCRIPT_DIR, "v1_v2_ids_matcher", "matched_ids.csv")
OUTPUT_FILE_PATH = os.path.join(SCRIPT_DIR, "sources", f"Fichier de suivi DTNUM with v2 ids {datetime.now().strftime('%Y%m%d')}.ods")


def read_original_file():
    print(f"Reading original file from {ORIGINAL_FILE_PATH}...")
    
    try:
        # Read the ODS file with header at row 3 (index 2)
        input_content = pd.read_excel(
            ORIGINAL_FILE_PATH,
            engine="odf",
            sheet_name='Demandes_accès',
            header=2
        )
        
        # Print the number of lines
        print(f"Number of lines in the input file: {len(input_content)}")
        return input_content
    except FileNotFoundError:
        print(f"Warning: Original file not found at {ORIGINAL_FILE_PATH}")
        print("Continuing with API testing only...")
        return None


def get_all_demandes(api_client):
    print("Iterating on all demandes from datapass...")
    
    all_demandes = []
    offset = 0
    limit = 100
    
    while True:
        demandes_page = api_client.get_demandes(limit=limit, offset=offset, states=["submitted", "changes_requested", "validated", "refused", "revoked"])
        if not demandes_page or len(demandes_page) == 0:
            break
            
        all_demandes.extend(demandes_page)
        print(f"Retrieved {len(demandes_page)} demandes (offset: {offset})")
        
        if len(demandes_page) < limit:
            break
            
        offset += limit
    
    print(f"Total demandes retrieved: {len(all_demandes)}")
    return all_demandes


def process_demande(demande, output_content):
    habilitations = api_client.get_habilitations_of_demande(demande['id'])
    
    if len(habilitations) == 0:
        add_demande_row(demande, output_content)
    else:
        for habilitation in habilitations:
            add_habilitation_row(habilitation, output_content)
        # TODO if demande is in some specific status, add another row for the demande.

def add_demande_row(demande, output_content):
    print(".", end="", flush=True)
    output_content.append(demande)

def add_habilitation_row(habilitation, output_content):
    print(".", end="", flush=True)
    output_content.append(habilitation)
    
    
        


def generate_output_content(all_demandes, input_content):
    output_content = []
    print("Processing demandes...")

    for demande in all_demandes:
        process_demande(demande, output_content)

    print("Done.")

    # TODO merge input content with output content
    # the key is the combo id demande + id habilitation
    # careful : sometimes we will have a demande who became an habilitation, in that case the combo is not ok
    # we should have a way to know if the habilitation is a new one or an updated one

    return output_content

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python update_suivi_dtnum.py <client_id> <client_secret>")
        sys.exit(1)
        
    client_id = sys.argv[1]
    client_secret = sys.argv[2]

    # Try to read the original file but continue if it doesn't exist
    input_content = read_original_file()
    
    # Initialize API client
    api_client = DataPassApiClient(client_id, client_secret)
    
    # Get token
    token_response = api_client.get_token()
    
    if token_response:
        print("\nAPI token obtained successfully from datapass")
        
        # Get all demandes using pagination
        all_demandes = get_all_demandes(api_client)
        output_content = generate_output_content(all_demandes, input_content)
        print(f"#{len(output_content)} rows generated")
        
        # print the output content in a file
        with open("lib/suivi_dtnum/sources/test_output_content.json", "w") as f:
            json.dump(output_content, f)
    else:
        print("Failed to obtain API token from datapass")