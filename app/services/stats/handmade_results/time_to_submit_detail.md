time to submit par type d'habilitation :

data-pass(prod):580> Stats::Report.new(date_range: 2025).print_time_to_submit_by_type_table; puts 'ok'

# Time to submit by Authorization Request Type of 2025:

Type                                               | Count |                  Min |                  Avg |                  Max
------------------------------------------------------------------------------------------------------------------------
APIRial Sandbox                                    |     1 |            5 minutes |            5 minutes |            5 minutes
Annuaire Des Entreprises                           |    70 |   moins d'une minute |            5 minutes |           31 minutes
APIDroits CNAM                                     |     1 |            6 minutes |            6 minutes |            6 minutes
APIIndemnites Journalieres CNAM                    |     2 |            4 minutes |            8 minutes |           12 minutes
APIMobilic                                         |     4 |            3 minutes |           11 minutes |           20 minutes
Le Taxi                                            |     7 |            3 minutes |           24 minutes |    environ une heure
Formulaire QF                                      |    77 |             1 minute |    environ 22 heures |      environ un mois
APISFi PR2PSandbox                                 |    11 |            5 minutes |               1 jour |             11 jours
Hub EEDila                                         |   459 |   moins d'une minute |               1 jour |               8 mois
APIFicoba                                          |     1 |               1 jour |               1 jour |               1 jour
Hub EECert DC                                      |   802 |   moins d'une minute |               1 jour |               6 mois
Pro Connect Identity Provider                      |    14 |            2 minutes |               1 jour |             10 jours
APIEntreprise                                      |   233 |   moins d'une minute |               1 jour |               3 mois
APIFicoba Sandbox                                  |    28 |             1 minute |              2 jours |             22 jours
APISFi PR2P                                        |    11 |            2 minutes |              2 jours |             21 jours
APIScolarite                                       |     1 |              3 jours |              3 jours |              3 jours
APIParticulier                                     |   574 |   moins d'une minute |              3 jours |               6 mois
APIDeclaration CESU                                |    45 |            2 minutes |              3 jours |               3 mois
APIPro Sante Connect                               |   232 |             1 minute |              5 jours |               9 mois
APIDeclaration Auto Entrepreneur                   |    23 |            2 minutes |              6 jours |      environ un mois
APICaptch Etat                                     |    33 |   moins d'une minute |              7 jours |               4 mois
Pro Connect Service Provider                       |    81 |            2 minutes |              7 jours |               9 mois
APIIngres                                          |     4 |            7 minutes |              8 jours |      environ un mois
APIR2PSandbox                                      |    20 |            3 minutes |              9 jours |               5 mois
France Connect                                     |   503 |             1 minute |             12 jours |              10 mois
APIINFINOESandbox                                  |    19 |            2 minutes |             15 jours |               8 mois
APIImpot Particulier                               |    28 |            4 minutes |             23 jours |               5 mois
APIImpot Particulier Sandbox                       |    10 |            2 minutes |             29 jours |               7 mois
APIRial                                            |     2 |           12 minutes |      environ un mois |               3 mois
APIINFINOE                                         |    14 |             1 minute |       environ 2 mois |              11 mois
APIR2P                                             |    20 |            4 minutes |       environ 2 mois |              10 mois
APISFi PSandbox                                    |     6 |           12 minutes |               2 mois |               8 mois
APISFi P                                           |    16 |            5 minutes |               4 mois |               9 mois
ok
=> nil
data-pass(prod):581> Stats::Report.new(date_range: 2024).print_time_to_submit_by_type_table; puts 'ok'

# Time to submit by Authorization Request Type of 2024:

Type                                               | Count |                  Min |                  Avg |                  Max
------------------------------------------------------------------------------------------------------------------------
Formulaire QF                                      |     3 |            2 minutes |            4 minutes |            8 minutes
Hub EECert DC                                      |   997 |   moins d'une minute |              5 jours |        presque 2 ans
Hub EEDila                                         |   384 |   moins d'une minute |             13 jours |         plus d'un an
APIEntreprise                                      |   178 |   moins d'une minute |      environ un mois |        environ 2 ans
APIParticulier                                     |   428 |   moins d'une minute |      environ un mois |        presque 2 ans
APIDeclaration Auto Entrepreneur                   |     1 |               5 mois |               5 mois |               5 mois
Pro Connect Service Provider                       |     1 |              10 mois |              10 mois |              10 mois
APIImpot Particulier Sandbox                       |     1 |              11 mois |              11 mois |              11 mois
APIR2P                                             |     8 |               6 mois |              12 mois |         plus d'un an
France Connect                                     |    71 |               6 mois |        environ un an |         plus d'un an
APIFicoba                                          |     1 |        environ un an |        environ un an |        environ un an
APIImpot Particulier                               |     5 |               8 mois |        environ un an |         plus d'un an
APIINFINOESandbox                                  |     8 |               9 mois |         plus d'un an |         plus d'un an
APIFicoba Sandbox                                  |     4 |               8 mois |         plus d'un an |         plus d'un an
APIPro Sante Connect                               |     3 |              12 mois |         plus d'un an |        presque 2 ans
APIINFINOE                                         |    20 |        environ un an |         plus d'un an |        presque 2 ans
APICaptch Etat                                     |     2 |        environ un an |         plus d'un an |        presque 2 ans
APIR2PSandbox                                      |     1 |         plus d'un an |         plus d'un an |         plus d'un an
ok
=> nil
data-pass(prod):582> Stats::Report.new(date_range: 2023).print_time_to_submit_by_type_table; puts 'ok'

# Time to submit by Authorization Request Type of 2023:

Type                                               | Count |                  Min |                  Avg |                  Max
------------------------------------------------------------------------------------------------------------------------
Hub EEDila                                         |  1055 |   moins d'une minute |              5 jours |        environ 3 ans
Hub EECert DC                                      |   407 |   moins d'une minute |             19 jours |        environ 3 ans
APIParticulier                                     |   373 |   moins d'une minute |               2 mois |        presque 3 ans
APIEntreprise                                      |   184 |   moins d'une minute |               3 mois |        presque 3 ans
APISFi P                                           |     3 |         plus d'un an |         plus d'un an |        presque 2 ans
APIINFINOESandbox                                  |     4 |         plus d'un an |        presque 2 ans |        environ 2 ans
APIImpot Particulier                               |     8 |         plus d'un an |        environ 2 ans |        presque 3 ans
APIR2P                                             |     6 |         plus d'un an |        environ 2 ans |        presque 3 ans
APIFicoba Sandbox                                  |     1 |        environ 2 ans |        environ 2 ans |        environ 2 ans
APIINFINOE                                         |     8 |         plus d'un an |        environ 2 ans |        plus de 2 ans
APIImpot Particulier Sandbox                       |     8 |         plus d'un an |        environ 2 ans |        plus de 2 ans
APIFicoba                                          |     2 |        environ 2 ans |        environ 2 ans |        plus de 2 ans
France Connect                                     |    34 |         plus d'un an |        environ 2 ans |        presque 3 ans
Pro Connect Identity Provider                      |     1 |        plus de 2 ans |        plus de 2 ans |        plus de 2 ans
APIPro Sante Connect                               |     3 |        environ 2 ans |        plus de 2 ans |        presque 3 ans
ok
