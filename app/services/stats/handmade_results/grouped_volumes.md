data-pass(prod):6381> Stats::Report.new(date_input: 2025).print_volume_by_type; puts 'ok'
data-pass(prod):6382> 

# Volume of authorization requests by type for 2025:

France Connect                   (994) │ ██████████████████████████████████████████████████
APIParticulier                   (873) │ ████████████████████████████████████████████
Hub EECert DC                    (864) │ ███████████████████████████████████████████
Hub EEDila                       (488) │ █████████████████████████
APIEntreprise                    (433) │ ██████████████████████
APIPro Sante Connect             (404) │ ████████████████████
Pro Connect Service Provider     (180) │ █████████
APIDeclaration CESU              (119) │ ██████
Formulaire QF                    ( 99) │ █████
Annuaire Des Entreprises         ( 95) │ █████
APIDeclaration Auto Entrepreneur ( 87) │ ████
APIR2P                           ( 85) │ ████
APIImpot Particulier             ( 71) │ ████
APIFicoba Sandbox                ( 68) │ ███
APICaptch Etat                   ( 67) │ ███
APIINFINOESandbox                ( 63) │ ███
APIR2PSandbox                    ( 59) │ ███
APIImpot Particulier Sandbox     ( 52) │ ███
APISFi P                         ( 32) │ ██
APISFi PSandbox                  ( 31) │ ██
APISFi PR2P                      ( 29) │ █
Pro Connect Identity Provider    ( 25) │ █
APISFi PR2PSandbox               ( 23) │ █
APIINFINOE                       ( 21) │ █
APIMobilic                       ( 16) │ █
APIRial Sandbox                  ( 15) │ █
Le Taxi                          ( 15) │ █
APIIngres                        ( 11) │ █
APIFicoba                        (  7) │ 
APIScolarite                     (  6) │ 
APIIndemnites Journalieres CNAM  (  4) │ 
APIRial                          (  3) │ 
APIImprimfip Sandbox             (  2) │ 
APIDroits CNAM                   (  1) │ 

Total: 5342 authorization requests
Scale: each █ represents 19.9 request(s)
ok
=> nil
data-pass(prod):6383> Stats::Report.new(date_input: 2025).print_volume_by_provider; puts 'ok'
data-pass(prod):6384> 

# Volume of authorization requests by provider for 2025:

DINUM                                                                               (2714) │ ██████████████████████████████████████████████████
Organisation de la direction générale de la santé (DGS)                             ( 864) │ ████████████████
DGFIP                                                                               ( 561) │ ██████████
Direction de l'information légale et administrative (DILA)                          ( 488) │ █████████
Agence du Numérique en Santé (ANS)                                                  ( 404) │ ███████
URSSAF                                                                              ( 206) │ ████
Agence pour l'Information Financière de l'État                                      (  67) │ █
Ministère de la Transition écologique                                               (  16) │ 
Centre Interministériel des Systèmes d'Information relatifs aux Ressources Humaines (  11) │ 
Ministère de l'Éducation Nationale et de la Jeunesse                                (   6) │ 
CNAM                                                                                (   5) │ 

Total: 5342 authorization requests
Scale: each █ represents 54.3 request(s)
ok


DINUM only :

data-pass(prod):6385> Stats::Report.new(date_input: 2025, provider: 'dinum').print_volume_by_type; puts 'ok'
data-pass(prod):6386> 

# Volume of authorization requests by type for 2025 (provider: dinum):

France Connect                (994) │ ██████████████████████████████████████████████████
APIParticulier                (873) │ ████████████████████████████████████████████
APIEntreprise                 (433) │ ██████████████████████
Pro Connect Service Provider  (180) │ █████████
Formulaire QF                 ( 99) │ █████
Annuaire Des Entreprises      ( 95) │ █████
Pro Connect Identity Provider ( 25) │ █
Le Taxi                       ( 15) │ █


Volumes with only validated/refused : 

data-pass(prod):7950> Stats::Report.new(date_input: 2025).print_volume_by_type_with_states; puts 'ok'
data-pass(prod):7951> 

# Volume of authorization requests by type (validated vs refused) for 2025:

Hub EECert DC                    (V:689 R: 11 T:700) │ █████████████████████████████████████████████████▓
France Connect                   (V:479 R:186 T:665) │ ██████████████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓
APIParticulier                   (V:480 R: 22 T:502) │ ██████████████████████████████████▓▓
Hub EEDila                       (V:312 R:  6 T:318) │ ██████████████████████
APIPro Sante Connect             (V:279 R: 11 T:290) │ ████████████████████▓
APIEntreprise                    (V:109 R: 64 T:173) │ ████████▓▓▓▓▓
Pro Connect Service Provider     (V: 96 R: 10 T:106) │ ███████▓
Formulaire QF                    (V: 59 R:  2 T: 61) │ ████
APIDeclaration CESU              (V:  9 R: 46 T: 55) │ █▓▓▓
APIINFINOESandbox                (V: 36 R: 19 T: 55) │ ███▓
Annuaire Des Entreprises         (V: 47 R:  8 T: 55) │ ███▓
APICaptch Etat                   (V: 48 R:  2 T: 50) │ ███
APIFicoba Sandbox                (V:  1 R: 36 T: 37) │ ▓▓▓
APIR2PSandbox                    (V: 13 R: 21 T: 34) │ █▓▓
APIDeclaration Auto Entrepreneur (V:  8 R: 23 T: 31) │ █▓▓
APIImpot Particulier Sandbox     (V: 11 R: 15 T: 26) │ █▓
Pro Connect Identity Provider    (V: 17 R:  0 T: 17) │ █
APIImpot Particulier             (V: 11 R:  6 T: 17) │ █
APIR2P                           (V: 12 R:  2 T: 14) │ █
APISFi PSandbox                  (V:  9 R:  3 T: 12) │ █
APIIngres                        (V:  9 R:  1 T: 10) │ █
APIRial Sandbox                  (V:  8 R:  1 T:  9) │ █
APIINFINOE                       (V:  0 R:  9 T:  9) │ ▓
APISFi P                         (V:  5 R:  2 T:  7) │ 
APISFi PR2PSandbox               (V:  4 R:  2 T:  6) │ 
APISFi PR2P                      (V:  1 R:  3 T:  4) │ 
APIScolarite                     (V:  3 R:  0 T:  3) │ 
APIMobilic                       (V:  3 R:  0 T:  3) │ 
Le Taxi                          (V:  1 R:  0 T:  1) │ 

Legend: █ = Validated, ▓ = Refused
Total: 2759 validated, 511 refused (3270 total)
Scale: each character represents 14.0 request(s)
ok
=> nil
data-pass(prod):7952> Stats::Report.new(date_input: 2025).print_volume_by_provider_with_states; puts 'ok'
data-pass(prod):7953> 

# Volume of authorization requests by provider (validated vs refused) for 2025:

DINUM                                                                               (V:1288 R: 292 T:1580) │ █████████████████████████████████████████▓▓▓▓▓▓▓▓▓
Organisation de la direction générale de la santé (DGS)                             (V: 689 R:  11 T: 700) │ ██████████████████████
Direction de l'information légale et administrative (DILA)                          (V: 312 R:   6 T: 318) │ ██████████
Agence du Numérique en Santé (ANS)                                                  (V: 279 R:  11 T: 290) │ █████████
DGFIP                                                                               (V: 111 R: 119 T: 230) │ ████▓▓▓▓
URSSAF                                                                              (V:  17 R:  69 T:  86) │ █▓▓
Agence pour l'Information Financière de l'État                                      (V:  48 R:   2 T:  50) │ ██
Centre Interministériel des Systèmes d'Information relatifs aux Ressources Humaines (V:   9 R:   1 T:  10) │ 
Ministère de la Transition écologique                                               (V:   3 R:   0 T:   3) │ 
Ministère de l'Éducation Nationale et de la Jeunesse                                (V:   3 R:   0 T:   3) │ 

Legend: █ = Validated, ▓ = Refused
Total: 2759 validated, 511 refused (3270 total)
Scale: each character represents 31.6 request(s)
ok
=> nil
data-pass(prod):7954> Stats::Report.new(date_input: 2025, provider: 'dinum').print_volume_by_type_with_states; puts 'ok'
data-pass(prod):7955> 

# Volume of authorization requests by type (validated vs refused) for 2025 (provider: dinum):

France Connect                (V:479 R:186 T:665) │ ████████████████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓
APIParticulier                (V:480 R: 22 T:502) │ ████████████████████████████████████▓▓
APIEntreprise                 (V:109 R: 64 T:173) │ ████████▓▓▓▓▓
Pro Connect Service Provider  (V: 96 R: 10 T:106) │ ███████▓
Formulaire QF                 (V: 59 R:  2 T: 61) │ ████
Annuaire Des Entreprises      (V: 47 R:  8 T: 55) │ ████▓
Pro Connect Identity Provider (V: 17 R:  0 T: 17) │ █
Le Taxi                       (V:  1 R:  0 T:  1) │ 

Legend: █ = Validated, ▓ = Refused
Total: 1288 validated, 292 refused (1580 total)
Scale: each character represents 13.3 request(s)
ok
