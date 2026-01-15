# ⚠️  Data Quality Warning

2023-2024 data was migrated from DataPass v1 in early 2025.
Event timestamps for these years were reconstructed and may not accurately
reflect actual user behavior (especially time-to-submit metrics).

================================================================================

 
# Report of 2025:

5324 authorization requests created
2020 reopen events

Average time to submit: 5 jours
Median time to submit: 5 minutes
Mode time to submit: moins d'une minute
Standard deviation time to submit: 27 jours

Average time to first instruction: 7 jours
Median time to first instruction: 1 jour
Mode time to first instruction: 1 minute
Standard deviation time to first instruction: 18 jours


# Volume of authorization requests by type for 2025:

```
FranceConnect                  (983) │ ██████████████████████████████████████████████████
APIParticulier                 (873) │ ████████████████████████████████████████████
HubEECertDC                    (864) │ ████████████████████████████████████████████
HubEEDila                      (488) │ █████████████████████████
APIEntreprise                  (433) │ ██████████████████████
APIProSanteConnect             (404) │ █████████████████████
ProConnectServiceProvider      (180) │ █████████
APIDeclarationCESU             (119) │ ██████
FormulaireQF                   ( 99) │ █████
AnnuaireDesEntreprises         ( 95) │ █████
APIDeclarationAutoEntrepreneur ( 87) │ ████
APIR2P                         ( 85) │ ████
APIImpotParticulier            ( 71) │ ████
APIFicobaSandbox               ( 68) │ ███
APICaptchEtat                  ( 67) │ ███
APIINFINOESandbox              ( 63) │ ███
APIR2PSandbox                  ( 59) │ ███
APIImpotParticulierSandbox     ( 51) │ ███
APISFiP                        ( 32) │ ██
APISFiPSandbox                 ( 31) │ ██
APISFiPR2P                     ( 29) │ █
ProConnectIdentityProvider     ( 25) │ █
APISFiPR2PSandbox              ( 23) │ █
APIINFINOE                     ( 21) │ █
APIMobilic                     ( 16) │ █
LeTaxi                         ( 15) │ █
APIRialSandbox                 ( 13) │ █
APIFicoba                      (  7) │ 
APIIngres                      (  7) │ 
APIScolarite                   (  6) │ 
APIIndemnitesJournalieresCNAM  (  4) │ 
APIRial                        (  3) │ 
APIImprimfipSandbox            (  2) │ 
APIDroitsCNAM                  (  1) │ 

Total: 5324 authorization requests
Scale: each █ represents 19.7 request(s)
```


# Volume of authorization requests by type (validated vs refused) for 2025:

```
HubEECertDC                    (701:  98.4%V   1.6%R) │ █████████████████████████████████████████████████▓
FranceConnect                  (654:  72.9%V  27.1%R) │ ██████████████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓
APIParticulier                 (502:  95.6%V   4.4%R) │ ██████████████████████████████████▓▓
HubEEDila                      (318:  98.1%V   1.9%R) │ ██████████████████████
APIProSanteConnect             (290:  96.2%V   3.8%R) │ ████████████████████▓
APIEntreprise                  (173:  63.0%V  37.0%R) │ ████████▓▓▓▓▓
ProConnectServiceProvider      (106:  90.6%V   9.4%R) │ ███████▓
FormulaireQF                   ( 61:  96.7%V   3.3%R) │ ████
APIINFINOESandbox              ( 55:  65.5%V  34.5%R) │ ███▓
AnnuaireDesEntreprises         ( 55:  85.5%V  14.5%R) │ ███▓
APIDeclarationCESU             ( 55:  16.4%V  83.6%R) │ █▓▓▓
APICaptchEtat                  ( 50:  96.0%V   4.0%R) │ ███
APIFicobaSandbox               ( 37:   2.7%V  97.3%R) │ ▓▓▓
APIR2PSandbox                  ( 34:  38.2%V  61.8%R) │ █▓
APIDeclarationAutoEntrepreneur ( 31:  25.8%V  74.2%R) │ █▓▓
APIImpotParticulierSandbox     ( 25:  40.0%V  60.0%R) │ █▓
ProConnectIdentityProvider     ( 17: 100.0%V   0.0%R) │ █
APIImpotParticulier            ( 17:  64.7%V  35.3%R) │ █
APIR2P                         ( 14:  85.7%V  14.3%R) │ █
APISFiPSandbox                 ( 12:  75.0%V  25.0%R) │ █
APIINFINOE                     (  9:   0.0%V 100.0%R) │ ▓
APISFiP                        (  7:  71.4%V  28.6%R) │ 
APIRialSandbox                 (  7:  85.7%V  14.3%R) │ 
APISFiPR2PSandbox              (  6:  66.7%V  33.3%R) │ 
APIIngres                      (  6: 100.0%V   0.0%R) │ 
APISFiPR2P                     (  4:  25.0%V  75.0%R) │ 
APIScolarite                   (  3: 100.0%V   0.0%R) │ 
APIMobilic                     (  3: 100.0%V   0.0%R) │ 
LeTaxi                         (  1: 100.0%V   0.0%R) │ 

Legend: █ = Validated, ▓ = Refused
Total: 2752 validated, 501 refused (3253 total)
Scale: each character represents 14.0 request(s)
```


# Time to submit by minute of 2025:

```
  <1 (   0) │ 
   1 (1070) │ ██████████████████████████████████████████████████
   2 ( 168) │ ████████
   3 ( 172) │ ████████
   4 ( 138) │ ██████
   5 ( 156) │ ███████
   6 (  92) │ ████
   7 ( 122) │ ██████
   8 (  89) │ ████
   9 (  86) │ ████
  10 (  63) │ ███
  11 (  63) │ ███
  12 (  58) │ ███
  13 (  47) │ ██
  14 (  38) │ ██
  15 (  40) │ ██
  16 (  28) │ █
  17 (  29) │ █
  18 (  16) │ █
  19 (  24) │ █
  20 (  15) │ █
  21 (  23) │ █
  22 (  17) │ █
  23 (   7) │ 
  24 (  13) │ █
  25 (  14) │ █
  26 (  13) │ █
  27 (  15) │ █
  28 (   4) │ 
  29 (   8) │ 
  30 (  11) │ █
  31 (   7) │ 
  32 (   7) │ 
  33 (   3) │ 
  34 (  11) │ █
  35 (  10) │ 
  36 (   6) │ 
  37 (   4) │ 
  38 (   4) │ 
  39 (   6) │ 
  40 (   4) │ 
  41 (   2) │ 
  42 (   6) │ 
  43 (   4) │ 
  44 (   5) │ 
  45 (   1) │ 
  46 (   0) │ 
  47 (   4) │ 
  48 (   5) │ 
  49 (   1) │ 
  50 (   6) │ 
  51 (   1) │ 
  52 (   1) │ 
  53 (   0) │ 
  54 (   1) │ 
  55 (   5) │ 
  56 (   6) │ 
  57 (   3) │ 
  58 (   5) │ 
  59 (   4) │ 
  60 (   6) │ 
> 60 ( 580) │ ███████████████████████████

Total: 3347 authorization requests
Scale: each █ represents 21.4 request(s)
```


# Time to first instruction by day of 2025:

```
  <1 (   0) │ 
   1 (2363) │ ██████████████████████████████████████████████████
   2 ( 602) │ █████████████
   3 ( 325) │ ███████
   4 ( 314) │ ███████
   5 ( 262) │ ██████
   6 ( 187) │ ████
   7 ( 185) │ ████
   8 ( 137) │ ███
   9 ( 104) │ ██
  10 (  62) │ █
  11 (  64) │ █
  12 (  78) │ ██
  13 (  74) │ ██
  14 (  58) │ █
  15 (  66) │ █
  16 (  39) │ █
  17 (  28) │ █
  18 (  25) │ █
  19 (  32) │ █
  20 (  34) │ █
  21 (  27) │ █
  22 (  33) │ █
  23 (  12) │ 
  24 (  19) │ 
  25 (  10) │ 
  26 (   8) │ 
  27 (  16) │ 
  28 (  11) │ 
  29 (   6) │ 
  30 (   6) │ 
> 30 ( 225) │ █████

Total: 5412 authorization requests
Scale: each █ represents 47.3 request(s)
```

 
# Report of 2024:

5697 authorization requests created
688 reopen events

Average time to submit: environ un mois
Median time to submit: moins d'une minute
Mode time to submit: moins d'une minute
Standard deviation time to submit: 4 mois

Average time to first instruction: 12 jours
Median time to first instruction: 1 jour
Mode time to first instruction: 2 minutes
Standard deviation time to first instruction: environ 2 mois


# Volume of authorization requests by type for 2024:

```
HubEECertDC                    (1145) │ ██████████████████████████████████████████████████
APIParticulier                 ( 845) │ █████████████████████████████████████
FranceConnect                  ( 796) │ ███████████████████████████████████
APIINFINOESandbox              ( 664) │ █████████████████████████████
HubEEDila                      ( 539) │ ████████████████████████
APIEntreprise                  ( 425) │ ███████████████████
APIProSanteConnect             ( 405) │ ██████████████████
APIDeclarationCESU             ( 142) │ ██████
APIINFINOE                     ( 102) │ ████
APICaptchEtat                  ( 101) │ ████
APIDeclarationAutoEntrepreneur ( 101) │ ████
ProConnectServiceProvider      (  98) │ ████
APIImpotParticulierSandbox     (  85) │ ████
APIR2PSandbox                  (  62) │ ███
APIFicobaSandbox               (  29) │ █
ProConnectIdentityProvider     (  26) │ █
APIImpotParticulier            (  24) │ █
LeTaxi                         (  23) │ █
APIR2P                         (  22) │ █
APISFiPSandbox                 (  21) │ █
APIIngres                      (  10) │ 
APIScolarite                   (  10) │ 
APIFicoba                      (   6) │ 
FormulaireQF                   (   5) │ 
APIDroitsCNAM                  (   4) │ 
APISFiP                        (   3) │ 
APIImprimfipSandbox            (   2) │ 
APIRialSandbox                 (   1) │ 
APICprProAdelieSandbox         (   1) │ 

Total: 5697 authorization requests
Scale: each █ represents 22.9 request(s)
```


# Volume of authorization requests by type (validated vs refused) for 2024:

```
HubEECertDC                    (989:  97.0%V   3.0%R) │ ████████████████████████████████████████████████▓▓
APIINFINOESandbox              (612:  76.6%V  23.4%R) │ ████████████████████████▓▓▓▓▓▓▓
FranceConnect                  (509:  68.2%V  31.8%R) │ ██████████████████▓▓▓▓▓▓▓▓
APIParticulier                 (497:  90.3%V   9.7%R) │ ███████████████████████▓▓
HubEEDila                      (367:  95.1%V   4.9%R) │ ██████████████████▓
APIProSanteConnect             (318:  76.4%V  23.6%R) │ ████████████▓▓▓▓
APIEntreprise                  (165:  70.3%V  29.7%R) │ ██████▓▓
APIDeclarationCESU             ( 93:  15.1%V  84.9%R) │ █▓▓▓▓
APICaptchEtat                  ( 78: 100.0%V   0.0%R) │ ████
ProConnectServiceProvider      ( 51:  96.1%V   3.9%R) │ ██
APIImpotParticulierSandbox     ( 51:  45.1%V  54.9%R) │ █▓
APIDeclarationAutoEntrepreneur ( 46:  10.9%V  89.1%R) │ ▓▓
APIR2PSandbox                  ( 43:  48.8%V  51.2%R) │ █▓
APIImpotParticulier            ( 19:  89.5%V  10.5%R) │ █
ProConnectIdentityProvider     ( 16:  93.8%V   6.3%R) │ █
APIFicobaSandbox               ( 15:  46.7%V  53.3%R) │ 
APISFiPSandbox                 ( 14:  57.1%V  42.9%R) │ 
APIR2P                         ( 13:  84.6%V  15.4%R) │ █
LeTaxi                         ( 12: 100.0%V   0.0%R) │ █
APIIngres                      (  5:  40.0%V  60.0%R) │ 
APIScolarite                   (  5: 100.0%V   0.0%R) │ 
APIINFINOE                     (  5:  20.0%V  80.0%R) │ 
APIFicoba                      (  2: 100.0%V   0.0%R) │ 
FormulaireQF                   (  2: 100.0%V   0.0%R) │ 
APISFiP                        (  1: 100.0%V   0.0%R) │ 
APICprProAdelieSandbox         (  1:   0.0%V 100.0%R) │ 

Legend: █ = Validated, ▓ = Refused
Total: 3205 validated, 724 refused (3929 total)
Scale: each character represents 19.8 request(s)
```


# Time to submit by minute of 2024:

```
  <1 (   0) │ 
   1 (1286) │ ██████████████████████████████████████████████████
   2 ( 118) │ █████
   3 (  50) │ ██
   4 (  39) │ ██
   5 (  27) │ █
   6 (  19) │ █
   7 (  31) │ █
   8 (  22) │ █
   9 (  19) │ █
  10 (   8) │ 
  11 (  13) │ █
  12 (  12) │ 
  13 (  15) │ █
  14 (  10) │ 
  15 (   8) │ 
  16 (   4) │ 
  17 (   5) │ 
  18 (  10) │ 
  19 (   3) │ 
  20 (   3) │ 
  21 (   4) │ 
  22 (   3) │ 
  23 (   2) │ 
  24 (   2) │ 
  25 (   6) │ 
  26 (   3) │ 
  27 (   4) │ 
  28 (   4) │ 
  29 (   0) │ 
  30 (   0) │ 
  31 (   5) │ 
  32 (   2) │ 
  33 (   1) │ 
  34 (   3) │ 
  35 (   1) │ 
  36 (   1) │ 
  37 (   1) │ 
  38 (   1) │ 
  39 (   2) │ 
  40 (   1) │ 
  41 (   3) │ 
  42 (   0) │ 
  43 (   0) │ 
  44 (   2) │ 
  45 (   0) │ 
  46 (   2) │ 
  47 (   0) │ 
  48 (   1) │ 
  49 (   0) │ 
  50 (   0) │ 
  51 (   0) │ 
  52 (   1) │ 
  53 (   0) │ 
  54 (   0) │ 
  55 (   0) │ 
  56 (   1) │ 
  57 (   0) │ 
  58 (   0) │ 
  59 (   1) │ 
  60 (   1) │ 
> 60 ( 353) │ ██████████████

Total: 2113 authorization requests
Scale: each █ represents 25.7 request(s)
```


# Time to first instruction by day of 2024:

```
  <1 (   0) │ 
   1 (3572) │ ██████████████████████████████████████████████████
   2 ( 735) │ ██████████
   3 ( 487) │ ███████
   4 ( 442) │ ██████
   5 ( 436) │ ██████
   6 ( 242) │ ███
   7 ( 227) │ ███
   8 ( 156) │ ██
   9 (  65) │ █
  10 (  62) │ █
  11 (  65) │ █
  12 (  61) │ █
  13 (  40) │ █
  14 (  46) │ █
  15 (  54) │ █
  16 (  25) │ 
  17 (  32) │ 
  18 (  23) │ 
  19 (  28) │ 
  20 (  26) │ 
  21 (  32) │ 
  22 (  18) │ 
  23 (  14) │ 
  24 (  10) │ 
  25 (   6) │ 
  26 (   6) │ 
  27 (   4) │ 
  28 (   8) │ 
  29 (  13) │ 
  30 (   9) │ 
> 30 ( 445) │ ██████

Total: 7389 authorization requests
Scale: each █ represents 71.4 request(s)
```

 
# Report of 2023:

5359 authorization requests created
0 reopen events

Average time to submit: environ 2 mois
Median time to submit: moins d'une minute
Mode time to submit: moins d'une minute
Standard deviation time to submit: 6 mois

Average time to first instruction: 15 jours
Median time to first instruction: 2 jours
Mode time to first instruction: 1 minute
Standard deviation time to first instruction: environ 2 mois


# Volume of authorization requests by type for 2023:

```
HubEEDila                      (1176) │ ██████████████████████████████████████████████████
HubEECertDC                    ( 878) │ █████████████████████████████████████
FranceConnect                  ( 720) │ ███████████████████████████████
APIParticulier                 ( 638) │ ███████████████████████████
APIProSanteConnect             ( 372) │ ████████████████
APIEntreprise                  ( 312) │ █████████████
APIINFINOESandbox              ( 202) │ █████████
APIImpotParticulierSandbox     ( 172) │ ███████
APIDeclarationAutoEntrepreneur ( 146) │ ██████
APIDeclarationCESU             ( 142) │ ██████
APIR2PSandbox                  ( 106) │ █████
APICaptchEtat                  ( 103) │ ████
APIINFINOE                     (  90) │ ████
APIFicobaSandbox               (  65) │ ███
APIImpotParticulier            (  56) │ ██
LeTaxi                         (  45) │ ██
ProConnectServiceProvider      (  42) │ ██
APIIngres                      (  24) │ █
APIR2P                         (  18) │ █
ProConnectIdentityProvider     (  17) │ █
APISFiPSandbox                 (  11) │ 
APISFiP                        (   9) │ 
APIFicoba                      (   7) │ 
APIDroitsCNAM                  (   3) │ 
APIOpaleSandbox                (   2) │ 
APIIndemnitesJournalieresCNAM  (   2) │ 
APIRobfSandbox                 (   1) │ 

Total: 5359 authorization requests
Scale: each █ represents 23.5 request(s)
```


# Volume of authorization requests by type (validated vs refused) for 2023:

```
HubEEDila                      (1126:  98.5%V   1.5%R) │ █████████████████████████████████████████████████▓
HubEECertDC                    ( 840:  92.4%V   7.6%R) │ ██████████████████████████████████▓▓▓
FranceConnect                  ( 456:  72.1%V  27.9%R) │ ███████████████▓▓▓▓▓▓
APIParticulier                 ( 421:  94.8%V   5.2%R) │ ██████████████████▓
APIProSanteConnect             ( 281:  90.7%V   9.3%R) │ ███████████▓
APIEntreprise                  ( 216:  75.9%V  24.1%R) │ ███████▓▓
APIINFINOESandbox              ( 172:  69.2%V  30.8%R) │ █████▓▓
APIDeclarationCESU             ( 109:   6.4%V  93.6%R) │ ▓▓▓▓▓
APIImpotParticulierSandbox     ( 107:  43.9%V  56.1%R) │ ██▓▓▓
APICaptchEtat                  (  83: 100.0%V   0.0%R) │ ████
APIR2PSandbox                  (  75:  37.3%V  62.7%R) │ █▓▓
APIFicobaSandbox               (  42:  26.2%V  73.8%R) │ ▓
APIINFINOE                     (  41: 100.0%V   0.0%R) │ ██
APIImpotParticulier            (  39:  94.9%V   5.1%R) │ ██
ProConnectServiceProvider      (  31:  67.7%V  32.3%R) │ █
APIDeclarationAutoEntrepreneur (  26:  34.6%V  65.4%R) │ ▓
LeTaxi                         (  19: 100.0%V   0.0%R) │ █
ProConnectIdentityProvider     (  14: 100.0%V   0.0%R) │ █
APIIngres                      (  12:  50.0%V  50.0%R) │ 
APIR2P                         (  11:  90.9%V   9.1%R) │ 
APISFiP                        (   8: 100.0%V   0.0%R) │ 
APISFiPSandbox                 (   6:  33.3%V  66.7%R) │ 
APIFicoba                      (   5:  60.0%V  40.0%R) │ 

Legend: █ = Validated, ▓ = Refused
Total: 3497 validated, 643 refused (4140 total)
Scale: each character represents 22.5 request(s)
```


# Time to submit by minute of 2023:

```
  <1 (   0) │ 
   1 (1506) │ ██████████████████████████████████████████████████
   2 ( 100) │ ███
   3 (  46) │ ██
   4 (  30) │ █
   5 (  13) │ 
   6 (   6) │ 
   7 (  11) │ 
   8 (   7) │ 
   9 (  10) │ 
  10 (   4) │ 
  11 (   9) │ 
  12 (   5) │ 
  13 (   3) │ 
  14 (   6) │ 
  15 (   3) │ 
  16 (   2) │ 
  17 (   2) │ 
  18 (   1) │ 
  19 (   7) │ 
  20 (   1) │ 
  21 (   1) │ 
  22 (   3) │ 
  23 (   3) │ 
  24 (   1) │ 
  25 (   2) │ 
  26 (   0) │ 
  27 (   1) │ 
  28 (   0) │ 
  29 (   0) │ 
  30 (   1) │ 
  31 (   1) │ 
  32 (   1) │ 
  33 (   0) │ 
  34 (   2) │ 
  35 (   1) │ 
  36 (   1) │ 
  37 (   1) │ 
  38 (   2) │ 
  39 (   0) │ 
  40 (   1) │ 
  41 (   1) │ 
  42 (   1) │ 
  43 (   0) │ 
  44 (   0) │ 
  45 (   0) │ 
  46 (   0) │ 
  47 (   1) │ 
  48 (   0) │ 
  49 (   1) │ 
  50 (   0) │ 
  51 (   0) │ 
  52 (   0) │ 
  53 (   2) │ 
  54 (   0) │ 
  55 (   1) │ 
  56 (   0) │ 
  57 (   0) │ 
  58 (   0) │ 
  59 (   0) │ 
  60 (   0) │ 
> 60 ( 297) │ ██████████

Total: 2098 authorization requests
Scale: each █ represents 30.1 request(s)
```


# Time to first instruction by day of 2023:

```
  <1 (   0) │ 
   1 (3154) │ ██████████████████████████████████████████████████
   2 ( 735) │ ████████████
   3 ( 466) │ ███████
   4 ( 370) │ ██████
   5 ( 345) │ █████
   6 ( 294) │ █████
   7 ( 280) │ ████
   8 ( 243) │ ████
   9 ( 124) │ ██
  10 (  91) │ █
  11 (  80) │ █
  12 (  87) │ █
  13 (  77) │ █
  14 (  70) │ █
  15 (  76) │ █
  16 (  45) │ █
  17 (  37) │ █
  18 (  47) │ █
  19 (  33) │ █
  20 (  46) │ █
  21 (  40) │ █
  22 (  52) │ █
  23 (  28) │ 
  24 (  19) │ 
  25 (  31) │ 
  26 (  22) │ 
  27 (  24) │ 
  28 (  30) │ 
  29 (  24) │ 
  30 (  28) │ 
> 30 ( 544) │ █████████

Total: 7542 authorization requests
Scale: each █ represents 63.1 request(s)
```

