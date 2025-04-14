import pytest
import pandas as pd
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ORIGINAL_FILE_PATH = os.path.join(SCRIPT_DIR, "sources", "Fichier de suivi DTNUM 1404 with v2 ids.ods")
NOT_DGFIP_DATAPASS_IDS = [59988, 63921, 60581, 57086]

# Generic methods

def check_unicity_of_ids(content, id_column):
    duplicates = content[content[id_column].duplicated(keep=False)]
    if len(duplicates) > 0:
        duplicate_values = duplicates[id_column].unique().tolist()
        message = f"Found {len(duplicate_values)} duplicates of {id_column}: {duplicate_values}"
        pytest.fail(message)

def check_valid_states(content, state_column, valid_states, id_column):
    invalid_rows = content[~content[state_column].isin(valid_states)]
    if len(invalid_rows) > 0:
        invalid_ids_and_states = invalid_rows[[id_column, state_column]].to_dict(orient='records')
        message = f"Found {len(invalid_ids_and_states)} invalid states for {id_column}: {invalid_ids_and_states}"
        pytest.fail(message)


#######################
# Test input content #
#######################

@pytest.fixture(scope="session")
def input_content():
    input_content = pd.read_excel(
        ORIGINAL_FILE_PATH,
        engine="odf",
        sheet_name='Demandes_accès',
        header=2
    )
    # These datapass ids are not DGFiP datapass ids
    input_content = input_content[~input_content['N° DataPass v1'].isin(NOT_DGFIP_DATAPASS_IDS)]
    return input_content


def test_unicity_of_habilitation_ids_in_input_content(input_content):
    habilitation_rows = input_content[input_content['N° Habilitation v2'].notna()]
    check_unicity_of_ids(habilitation_rows, 'N° Habilitation v2')

def test_unicity_of_demande_ids_in_input_content(input_content):
    demande_rows = input_content[input_content['N° Habilitation v2'].isnull() & input_content['N° Demande v2'].notna()]
    check_unicity_of_ids(demande_rows, 'N° Demande v2')

def test_state_of_datapass_v1_without_demande_id_in_input_content(input_content):
    datapass_v1_without_demande_id = input_content[input_content['N° Demande v2'].isnull()]
    # Ignore the Supprimé and Refusé states as they are not undergo any evolutions
    check_valid_states(datapass_v1_without_demande_id, 'Statut', ["Supprimé", "Refusé"], 'N° DataPass v1')

# def test_state_of_habilitation_in_input_content(input_content):
#     valid_states = ["Accepté", "Accepté (obsolète)", "Révoqué"]
#     habilitation_rows = input_content[input_content['N° Habilitation v2'].notna()]
#     check_valid_states(habilitation_rows, 'Statut', valid_states, 'N° Habilitation v2')

# def test_state_of_demande_in_input_content(input_content):
#     # "Accepté" is a valid state for a demande before we merge the input content with the datapass content
#     valid_states = ["Traitement en cours par la DGFiP", "Modifications demandées au partenaire", "Refusé", "Supprimé", "Accepté"]
#     demande_rows = input_content[input_content['N° Habilitation v2'].isnull()]
#     check_valid_states(demande_rows, 'Statut', valid_states, 'N° DataPass v1')


#########################
# Test datapass content #
#########################

@pytest.fixture(scope="session")
def datapass_content():
    return pd.read_csv("lib/suivi_dtnum/sources/test_datapass_content.csv", quoting=1)

def test_unicity_of_habilitations_in_datapass_content(datapass_content):
    habilitation_rows = datapass_content[datapass_content['N° Habilitation v2'].notna()]
    check_unicity_of_ids(habilitation_rows, 'N° Habilitation v2')

def test_unicity_of_demandes_in_datapass_content(datapass_content):
    demande_rows = datapass_content[datapass_content['N° Habilitation v2'].isnull()]
    check_unicity_of_ids(demande_rows, 'N° Demande v2')

def test_state_of_habilitations_in_datapass_content(datapass_content):
    valid_states = ["Accepté", "Accepté (obsolète)", "Révoqué"]
    rows_with_habilitation = datapass_content[datapass_content['N° Habilitation v2'].notna()]
    check_valid_states(rows_with_habilitation, 'Statut', valid_states, 'N° Habilitation v2')

def test_state_of_demandes_in_datapass_content(datapass_content):
    valid_states = ["Traitement en cours par la DGFiP", "Modifications demandées au partenaire", "Refusé", "Supprimé"]
    rows_with_demande = datapass_content[datapass_content['N° Habilitation v2'].isnull()]
    check_valid_states(rows_with_demande, 'Statut', valid_states, 'N° Demande v2')

#######################
# Test output content #
#######################

@pytest.fixture(scope="session")
def output_content():
    output_content = pd.read_csv("lib/suivi_dtnum/sources/test_output_content.csv", quoting=1)
    output_content = output_content[~output_content['N° DataPass v1'].isin(NOT_DGFIP_DATAPASS_IDS)]
    return output_content

def test_unicity_of_habilitation_in_output_content(output_content):
    rows_with_habilitation = output_content[output_content['N° Habilitation v2'].notna()]
    check_unicity_of_ids(rows_with_habilitation, 'N° Habilitation v2')

def test_unicity_of_demande_in_output_content(output_content):
    rows_with_demande = output_content[output_content['N° Habilitation v2'].isnull() & output_content['N° Demande v2'].notna()]
    check_unicity_of_ids(rows_with_demande, 'N° Demande v2')

def test_state_of_habilitation_in_output_content(output_content):
    valid_states = ["Accepté", "Accepté (obsolète)", "Révoqué"]
    rows_with_habilitation = output_content[output_content['N° Habilitation v2'].notna()]
    check_valid_states(rows_with_habilitation, 'Statut', valid_states, 'N° Habilitation v2')

def test_state_of_demande_in_output_content(output_content):
    valid_states = ["Traitement en cours par la DGFiP", "Modifications demandées au partenaire", "Refusé", "Supprimé"]
    rows_with_demande = output_content[output_content['N° Habilitation v2'].isnull()]
    check_valid_states(rows_with_demande, 'Statut', valid_states, 'N° Demande v2')
    
def test_presence_of_raison_sociale_in_output_content(output_content):
    not_archived_rows = output_content[output_content['Statut'] != 'Supprimé']
    rows_without_raison_sociale = not_archived_rows[not_archived_rows['Raison sociale demandeur'].isnull()]
    if len(rows_without_raison_sociale) > 0:
        ids = rows_without_raison_sociale['N° Demande v2'].tolist()
        pytest.fail(f"Found {len(rows_without_raison_sociale)} rows without 'Raison sociale demandeur', N° Demande v2 : {ids}")

###############################
# Test leftover input content #
###############################

@pytest.fixture(scope="session")
def leftover_input_content():
    leftover_input_content = pd.read_csv("lib/suivi_dtnum/sources/leftover_input_content.csv", quoting=1)
    leftover_input_content = leftover_input_content[~leftover_input_content['N° DataPass v1'].isin(NOT_DGFIP_DATAPASS_IDS)]
    return leftover_input_content

@pytest.fixture(scope="session")
def leftover_datapass_content():
    return pd.read_csv("lib/suivi_dtnum/sources/leftover_datapass_content.csv", quoting=1)

def test_state_of_leftover_input_content(leftover_input_content):
    valid_states = ["Supprimé", "Brouillon", "Refusé"]
    invalid_rows = leftover_input_content[~leftover_input_content['Statut'].isin(valid_states)]
    assert len(invalid_rows) == 0, f"Found {len(invalid_rows)} rows with invalid state in leftover input content. N° DataPass v1 and status: {invalid_rows[['N° DataPass v1', 'Statut']].values.tolist()}"

def test_state_of_leftover_datapass_content(leftover_datapass_content):
    valid_states = ["Brouillon", "Supprimé"]
    invalid_rows = leftover_datapass_content[~leftover_datapass_content['Statut'].isin(valid_states)]
    assert len(invalid_rows) == 0, f"Found {len(invalid_rows)} rows with invalid state in leftover datapass content. N° Demande v2 and status: {invalid_rows[['N° Demande v2', 'Statut']].values.tolist()}"