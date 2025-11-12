import sys
import os
import time
from suivi_dtnum_updater import SuiviDtnumUpdater

# Define paths relative to the script's directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_FILE_PATH = os.path.join(SCRIPT_DIR, "sources", "Fichier de suivi DTNUM 1404 with v2 ids.ods")
OUTPUT_FILE_PATH = os.path.join(SCRIPT_DIR, "sources", time.strftime("%Y%m%d-%H%M%S") + "-fichier-suivi-maj.xlsx")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python update_suivi_dtnum.py <client_id> <client_secret>")
        sys.exit(1)
        
    client_id = sys.argv[1]
    client_secret = sys.argv[2]

    updater = SuiviDtnumUpdater(client_id, client_secret)
    updater.run(INPUT_FILE_PATH, OUTPUT_FILE_PATH)