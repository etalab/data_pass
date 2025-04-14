import pandas as pd
from datapass_api_client import DataPassApiClient
from datapass_row_maker import DatapassRowMaker

class SuiviDtnumUpdater:
    def __init__(self, client_id, client_secret):
        self.client_id = client_id
        self.client_secret = client_secret

    def run(self, input_file_path, output_file_path):
        input_content = self.read_input_file(input_file_path)
        
        api_client = DataPassApiClient(self.client_id, self.client_secret)
        all_demandes = api_client.get_all_demandes()

        self.generate_output_content(all_demandes, input_content, output_file_path)
        print("\nAll done.")


    def read_input_file(self, input_file_path):
        print(f"Reading original file from {input_file_path}...")
        
        try:
            # Read the ODS file with header at row 3 (index 2)
            input_content = pd.read_excel(
                input_file_path,
                engine="odf",
                sheet_name='Demandes_accès',
                header=2
            )
            
            # Print the number of lines
            print(f"Number of lines in the input file: {len(input_content)}")
            return input_content
        except FileNotFoundError as e:
            print(f"Original file not found at {input_file_path}")
            raise e

    def make_datapass_content_from_demandes(self, all_demandes):
        print("Making datapass rows...")
        
        datapass_rows = []
        for demande in all_demandes:
            # ignore the drafts and archived without habilitations
            if not ((demande["state"] in ["draft", "archived"]) & (len(demande["habilitations"]) == 0)):
                datapass_rows.extend(DatapassRowMaker(demande).make_rows_from_demande())
        
        datapass_content = pd.DataFrame(datapass_rows)
        print(f"{len(datapass_content)} Datapass rows generated.")
        return datapass_content



    def merge_demandes_and_habilitations(self, input_content, datapass_content):
        output_rows = []

        for input_row_index, input_row in input_content.iterrows():
            # Check if the row has a habilitation or not
            has_habilitation = not pd.isnull(input_row["N° Habilitation v2"])
            
            if has_habilitation:
                # Handle rows with habilitations
                datapass_rows = datapass_content[(datapass_content["N° Demande v2"] == input_row["N° Demande v2"]) & 
                                                (datapass_content["N° Habilitation v2"] == input_row["N° Habilitation v2"])]
            else:
                # Handle rows without habilitations
                datapass_rows = datapass_content[(datapass_content["N° Demande v2"] == input_row["N° Demande v2"]) & 
                                                (datapass_content["N° Habilitation v2"].isnull())]
                
            if len(datapass_rows) == 0:
                # We will check rows with no match in merge_demandes_with_new_habilitations later
                continue
            elif len(datapass_rows) == 1:
                datapass_row = datapass_rows.iloc[0]
                output_row = self.merge_input_row_and_datapass_row(input_row, datapass_row)
                output_rows.append(output_row)
                datapass_content.drop(datapass_rows.index, inplace=True)
                input_content.drop(input_row_index, inplace=True)
            else:
                habilitation_info = f"and N° Habilitation {input_row['N° Habilitation v2']}" if has_habilitation else "and N° Habilitation empty"
                raise Exception(f"Found several rows with N° Demande {input_row['N° Demande v2']} {habilitation_info} in datapass content")

        return output_rows

    def merge_demandes_with_new_habilitations(self, input_content, datapass_content):
        output_rows = []

        for input_row_index, input_row in input_content.iterrows():
            datapass_rows = datapass_content[(datapass_content['N° Demande v2'] == input_row['N° Demande v2']) & ~datapass_content['N° Habilitation v2'].isnull()]

            if len(datapass_rows) == 0:
                continue
            elif len(datapass_rows) == 1:
                datapass_row = datapass_rows.iloc[0]
                output_row = self.merge_input_row_and_datapass_row(input_row, datapass_row)
                output_rows.append(output_row)
                datapass_content.drop(datapass_rows.index, inplace=True)
                input_content.drop(input_row_index, inplace=True)
            else:
                raise(f"Found several rows with N° Demande {input_row['N° Demande v2']} in datapass content")
        
        return output_rows

    def merge_input_row_and_datapass_row(self, input_row, datapass_row):
        # We want to overwrite only these colomns from input with datapass content. The rest is overwritten only if it's empty in input.
        mandatory_columns_to_overwrite = ['Statut', 'Nom projet', 'Description projet', 'Destinataires des données', 'Date prévisionnelle d\'ouverture de service', 'Volumétrie', 'Date de dernière soumission']
        # This makes a copy of the input_row without the columns we want to overwrite
        cleaned_input_row = input_row.drop(columns=mandatory_columns_to_overwrite)
        # This updates the cleaned_input_row empty values with the datapass_row values
        # then this updates the result with the initial input_row values in case there were some empty values left in mandatory columns
        # (Note : We might need to adapt the combination differently for the v1 and the v2 data)
        return cleaned_input_row.combine_first(datapass_row).combine_first(input_row)

    def add_leftover_datapass(self, datapass_content):
        output_rows = []
        relevant_datapasses = datapass_content[~datapass_content['Statut'].isin(["Brouillon", "Supprimé"])]

        for _, datapass_row in relevant_datapasses.iterrows():
            output_rows.append(datapass_row)
            datapass_content.drop(datapass_row.name, inplace=True)

        return output_rows

    def merge_input_and_datapass_content(self, input_content, datapass_content):
        print(f"Lengths of contents before merging : input: {len(input_content)} datapass: {len(datapass_content)}")
        output_rows = self.merge_demandes_and_habilitations(input_content, datapass_content)
        print(f"Lengths of contents after merging demandes and habilitations : input: {len(input_content)} datapass: {len(datapass_content)}")

        # We check the demandes with new habilitations after the first merge
        # because we want to be sure of which habilitation row is merging with the former demande row
        # so we wait for the first pass to match all the former habilitations.
        output_rows.extend(self.merge_demandes_with_new_habilitations(input_content, datapass_content))
        print(f"Lengths of contents after merge new habilitations : input: {len(input_content)} datapass: {len(datapass_content)}")

        # add the new content from datapass that doesn't match any input content
        output_rows.extend(self.add_leftover_datapass(datapass_content))
        print(f"Lengths of contents after adding leftover datapass content : input: {len(input_content)} datapass: {len(datapass_content)}")

        # add the leftover input content that we couldn't match with datapass
        for _, row in input_content.iterrows():
            output_rows.append(row)

        # create files with the leftover contents
        print(f"Leftover input content : {len(input_content)} -> Check the file leftover_input_content.csv")
        input_content.to_csv("lib/suivi_dtnum/sources/leftover_input_content.csv", index=False, quoting=1)
        print(f"Leftover datapass content : {len(datapass_content)} -> Check the file leftover_datapass_content.csv")
        datapass_content.to_csv("lib/suivi_dtnum/sources/leftover_datapass_content.csv", index=False, quoting=1)

        # Convert list to DataFrame once at the end
        output_content = pd.DataFrame(output_rows)

        # sort the headers in the same order as the original file
        output_content = output_content[input_content.columns]

        # sort rows by N° Datapass v1 then N° Demande v2, then N° Habilitation v2
        output_content = output_content.sort_values(by=['N° DataPass v1', 'N° Demande v2', 'N° Habilitation v2'])

        print(f"#{len(output_content)} rows after merging input and datapass content")
        return output_content


    def generate_output_content(self, all_demandes, input_content, output_file_path):
        datapass_content = self.make_datapass_content_from_demandes(all_demandes)
        datapass_content.to_csv("lib/suivi_dtnum/sources/test_datapass_content.csv", index=False, quoting=1)

        output_content = self.merge_input_and_datapass_content(input_content, datapass_content)
        output_content.to_csv("lib/suivi_dtnum/sources/test_output_content.csv", index=False, quoting=1)

        # print the output content in an excel file
        with pd.ExcelWriter(output_file_path) as writer:
            output_content.to_excel(writer, sheet_name='result', index=False)

        print(f"Output file saved to {output_file_path}")
