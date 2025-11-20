from dateutil import parser
import datapass_data_correspondances as data_correspondances

class DatapassRowMaker:
    def __init__(self, demande):
        self.demande = demande

    def format_date(self, date_str):
        """Convert a date string to DD/MM/YYYY format"""
        if not date_str:
            return ""
        try:
            dt = parser.parse(date_str)
            return dt.strftime('%d/%m/%Y')
        except (ValueError, AttributeError, TypeError):
            return date_str

    def make_rows_from_demande(self):
        rows = []
        habilitations = self.demande['habilitations']

        if len(habilitations) == 0:
            if self.demande['state'] not in ['draft']:
                rows.append(self.format_demande_row())
        else:
            for habilitation in habilitations:
                rows.append(self.format_habilitation_row(habilitation))
            # If the demande is still being instructed, add another row for the demande.
            if self.demande['state'] in ["submitted", "changes_requested", "refused"]:
                rows.append(self.format_demande_row())
        
        return rows

    def format_demande_row(self):
        row = {}
        row["N° Demande v2"] = self.demande["id"]
        row["N° Habilitation v2"] = None
        row["Environnement"] = data_correspondances.match_environnement(self.demande["form_uid"], self.demande["type"])
        row["API"] = data_correspondances.match_api_name(self.demande["type"])
        row["Type"] = "Avenant" if self.demande["reopening"] else "Initial"
        row["Modèle pré-rempli / cas d'usage"] = data_correspondances.match_cas_dusage(self.demande["form_uid"])

        row = self.format_data_attributes(row, self.demande["data"])
        row["Date de création / réception"] = self.format_date(self.demande['reopened_at'] or self.demande["created_at"])
        row["Date de dernière soumission"] = self.format_date(self.demande["last_submitted_at"]) # TODO : make a new column for this, and keep the updated_at to have the last "answer" date
        row["Statut"] = data_correspondances.match_statut(self.demande["state"]) 
        
        # Get SIRET safely from nested dictionary
        organisation = self.demande.get("organisation", {})
        row["SIRET demandeur"] = organisation["siret"]

        insee_payload = organisation.get("insee_payload", {})
        etablissement = insee_payload.get("etablissement", {})
        unite_legale = etablissement.get("uniteLegale", {})
        row['Raison sociale demandeur'] = unite_legale.get("denominationUniteLegale")
        adresse = etablissement.get("adresseEtablissement", {})
        row['Code postal'] = adresse.get("codePostalEtablissement")
        row['Ville'] = adresse.get("libelleCommuneEtablissement")
        department_number = row['Code postal'][:2] if row['Code postal'] else None
        # TODO : utiliser l'API Adresse : https://adresse.data.gouv.fr/outils/api-doc/adresse
        row['Département'] = department_number
        row['Région'] = None

        return row

    def format_habilitation_row(self, habilitation):
        row = self.format_demande_row()
        row["N° Habilitation v2"] = habilitation["id"]
        row["Environnement"] = data_correspondances.match_environnement(self.demande["form_uid"], habilitation["authorization_request_class"])
        row["API"] = data_correspondances.match_api_name(habilitation["authorization_request_class"])

        row = self.format_data_attributes(row, habilitation["data"])
        row.pop("Date de dernière soumission") # Don't overwrite the Date de dernière soumission, because it might have been reopened since
        row["Statut"] = data_correspondances.match_statut(habilitation["state"])

        return row

    def format_data_attributes(self, row, data):
        row["Nom projet"] = data.get("intitule")
        row["Description projet"] = data.get("description")
        row["Destinataires des données"] = data.get("destinataire_donnees_caractere_personnel")
        row["Date prévisionnelle d'ouverture de service"] = self.format_date(data.get("date_prevue_mise_en_production"))
        row["Volumétrie"] = data.get("volumetrie_appels_par_minute")
        
        return row