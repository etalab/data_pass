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
        demandes_page = api_client.get_demandes(limit=limit, offset=offset, states=["submitted", "changes_requested", "validated", "refused", "archived", "revoked"])
        if not demandes_page or len(demandes_page) == 0:
            break
            
        all_demandes.extend(demandes_page)
        print(f"Retrieved {len(demandes_page)} demandes (offset: {offset})")
        
        if len(demandes_page) < limit:
            break
            
        offset += limit
    
    print(f"Total demandes retrieved: {len(all_demandes)}")
    return all_demandes

def process_demande(demande, input_content, output_content):
    # Find rows matching the demande id - convert column values to int for comparison
    matching_rows = input_content[input_content['N° Demande v2'] == demande['id']]

    if matching_rows.empty:
        # If the demande is archived, it's ok to not find it in the input file
        if demande['state'] == "archived":
            return
        else:
            add_new_rows(demande, output_content)
    else:
        update_rows(matching_rows, demande)


def add_new_rows(demande, output_content):
    print(f"New demande #{demande['id']}", end="", flush=True)

def update_rows(matching_rows, demande):
    print(".", end="", flush=True)
    # print(f"Updating rows for demande #{demande['id']}")


def generate_output_content(all_demandes, input_content):
    output_content = []
    print("Processing demandes...")

    for demande in all_demandes:
        process_demande(demande, input_content, output_content)

    print("Done.")
    
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
        print(len(output_content))
    else:
        print("Failed to obtain API token from datapass")