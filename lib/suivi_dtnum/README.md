# Fichier de suivi DTNUM

## Initialisation du fichier post-migration

1. Récupérer la dernière version du fichier de suivi
2. Renommer la colonne "N° DataPass v1" en "N° DataPass v1" + ajouter "Date de dernière soumission"
3. Extraire les IDs de V2 des datapass du fichier de suivi depuis la prod
4. Insérer les IDs de v2 dans 2 nouvelles colonnes du fichier de suivi "N° Demande v2" et "N° Habilitation v2"
5. Générer des credentials d'accès à l'API pour un user dgfip (maimouna ?)
6. Faire tourner le script `main.py` avec ces credentials et le fichier de suivi pour générer un nouveau fichier à jour

## Mise à jour du fichier après initialisation

Faire tourner le script `main.py` avec les credentials sus-cités et le dernier fichier de suivi

# Instructions pour update_suivi_dtnum.py

1. Create a virtual environment:
```bash
python3 -m venv venv
```

2. Activate the virtual environment:
- On Linux/Mac:
```bash
source venv/bin/activate
```
- On Windows:
```bash
.\venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r lib/suivi_dtnum/requirements.txt
```

## Usage

The main script can be run with:
```bash
python3 lib/suivi_dtnum/update_suivi_dtnum.py <client_id> <client_secret>
```

Make sure to provide your client credentials as command line arguments when running the script. 