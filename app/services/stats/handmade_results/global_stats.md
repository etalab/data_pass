data-pass(prod):5810> [2026, 2025, 2024, 2023].each{ |year| Stats::Report.new(date_input: year).print_report }; puts 'ok'
 
# Report of 2026:

294 authorization requests created
89 reopen events

Average time to submit: environ 5 heures
Median time to submit: 3 minutes
Standard deviation time to submit: 1 jour

Average time to first instruction: environ 20 heures
Median time to first instruction: environ 3 heures
Standard deviation time to first instruction: 1 jour
 
# Report of 2025:

5342 authorization requests created
2020 reopen events

Average time to submit: 5 jours
Median time to submit: 5 minutes
Standard deviation time to submit: 27 jours

Average time to first instruction: 7 jours
Median time to first instruction: 1 jour
Standard deviation time to first instruction: 18 jours
 
# Report of 2024:

5738 authorization requests created
688 reopen events

Average time to submit: environ un mois
Median time to submit: moins d'une minute
Standard deviation time to submit: 4 mois

Average time to first instruction: 12 jours
Median time to first instruction: 1 jour
Standard deviation time to first instruction: environ 2 mois
 
# Report of 2023:

5416 authorization requests created
0 reopen events

Average time to submit: environ 2 mois
Median time to submit: moins d'une minute
Standard deviation time to submit: 6 mois

Average time to first instruction: 15 jours
Median time to first instruction: 2 jours
Standard deviation time to first instruction: environ 2 mois
ok
=> nil
data-pass(prod):5811> [2026, 2025, 2024, 2023].each{ |year| Stats::Report.new(date_input: year, provider: 'dinum').print_report }; puts 'ok'
 
# Report of 2026 (provider: dinum):

137 authorization requests created
48 reopen events

Average time to submit: environ 8 heures
Median time to submit: 8 minutes
Standard deviation time to submit: 1 jour

Average time to first instruction: 1 jour
Median time to first instruction: environ 19 heures
Standard deviation time to first instruction: 1 jour
 
# Report of 2025 (provider: dinum):

2714 authorization requests created
1515 reopen events

Average time to submit: 6 jours
Median time to submit: 11 minutes
Standard deviation time to submit: 27 jours

Average time to first instruction: 7 jours
Median time to first instruction: 3 jours
Standard deviation time to first instruction: 10 jours
 
# Report of 2024 (provider: dinum):

2225 authorization requests created
456 reopen events

Average time to submit: 2 mois
Median time to submit: 11 minutes
Standard deviation time to submit: 5 mois

Average time to first instruction: 6 jours
Median time to first instruction: 3 jours
Standard deviation time to first instruction: 13 jours
 
# Report of 2023 (provider: dinum):

1785 authorization requests created
0 reopen events

Average time to submit: 4 mois
Median time to submit: 4 minutes
Standard deviation time to submit: 9 mois

Average time to first instruction: 8 jours
Median time to first instruction: 3 jours
Standard deviation time to first instruction: 18 jours
ok
=> nil
data-pass(prod):5812> [2026, 2025, 2024, 2023].each{ |year| Stats::Report.new(date_input: year, provider: 'dgfip').print_report }; puts 'ok'
 
# Report of 2026 (provider: dgfip):

29 authorization requests created
8 reopen events

Average time to submit: environ 3 heures
Median time to submit: 9 minutes
Standard deviation time to submit: environ 6 heures

Average time to first instruction: 3 jours
Median time to first instruction: 3 jours
Standard deviation time to first instruction: 3 jours
 
# Report of 2025 (provider: dgfip):

561 authorization requests created
123 reopen events

Average time to submit: environ un mois
Median time to submit: 27 minutes
Standard deviation time to submit: 2 mois

Average time to first instruction: 10 jours
Median time to first instruction: 2 jours
Standard deviation time to first instruction: environ un mois
 
# Report of 2024 (provider: dgfip):

1053 authorization requests created
0 reopen events

Average time to submit: plus d'un an
Median time to submit: plus d'un an
Standard deviation time to submit: 4 mois

Average time to first instruction: 20 jours
Median time to first instruction: environ 3 heures
Standard deviation time to first instruction: 3 mois
 
# Report of 2023 (provider: dgfip):

777 authorization requests created
0 reopen events

Average time to submit: environ 2 ans
Median time to submit: environ 2 ans
Standard deviation time to submit: 5 mois

Average time to first instruction: 24 jours
Median time to first instruction: 5 jours
Standard deviation time to first instruction: 3 mois
ok
