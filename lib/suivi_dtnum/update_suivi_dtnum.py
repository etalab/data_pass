import json
import sys
import os
import pandas as pd
from datetime import datetime
from datapass_api_client import DataPassApiClient
import datapass_data_correspondances as data_correspondances

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
    habilitations = demande['habilitations']

    if len(habilitations) == 0:
        output_content = add_demande_row(demande, output_content)
    else:
        for habilitation in habilitations:
            output_content = add_habilitation_row(demande, habilitation, output_content)
        # If the demande is still being instructed, add another row for the demande.
        if demande['state'] in ["submitted", "changes_requested", "refused"]:
            output_content = add_demande_row(demande, output_content)
    
    return output_content


def add_demande_row(demande, output_content):
    print(".", end="", flush=True)
    row = format_demande_row(demande)
    return pd.concat([output_content, pd.DataFrame([row])], ignore_index=True)

def add_habilitation_row(demande, habilitation, output_content):
    print(".", end="", flush=True)
    row = format_habilitation_row(demande, habilitation)
    return pd.concat([output_content, pd.DataFrame([row])], ignore_index=True)


def format_demande_row(demande):
    row = {}
    row["N° Demande v2"] = demande["id"]
    row["N° Habilitation v2"] = ""
    row["API"] = data_correspondances.api_names[demande["type"]]
    row["Environnement"] = data_correspondances.api_environnments[demande["type"]]
    row["Type"] = "Initial"
    return row

def format_habilitation_row(demande, habilitation):
    row = format_demande_row(demande)
    row["N° Habilitation v2"] = habilitation["id"]

    # if the demande has one other validated habilitation of the same type, it's an avenant
    print(habilitation)
    if demande["habilitations"].count(lambda h  : h["type"] == habilitation["type"] and not h["revoked"]) > 1:
        row["Type"] = "Avenant"
    
    return row


def generate_output_content(all_demandes, input_content):
    output_content = pd.DataFrame()
    print("Processing demandes...")

    for demande in all_demandes:
        output_content = process_demande(demande, output_content)

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
        
        # print the output content in a csv file
        output_content.to_csv("lib/suivi_dtnum/sources/test_output_content.csv", index=False)
    else:
        print("Failed to obtain API token from datapass")