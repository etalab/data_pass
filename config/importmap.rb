# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "stimulus-library", to: "https://ga.jspm.io/npm:stimulus-library@1.2.1/dist/index.js"
pin "@stimulus-library/controllers", to: "https://ga.jspm.io/npm:@stimulus-library/controllers@1.2.1/dist/index.js"
pin "@stimulus-library/mixins", to: "https://ga.jspm.io/npm:@stimulus-library/mixins@1.2.1/dist/index.js"
pin "@stimulus-library/utilities", to: "https://ga.jspm.io/npm:@stimulus-library/utilities@1.2.1/dist/index.js"
pin "date-fns/formatDistanceToNow", to: "https://ga.jspm.io/npm:date-fns@3.6.0/formatDistanceToNow.mjs"
pin "date-fns/formatDuration", to: "https://ga.jspm.io/npm:date-fns@3.6.0/formatDuration.mjs"
pin "date-fns/intervalToDuration", to: "https://ga.jspm.io/npm:date-fns@3.6.0/intervalToDuration.mjs"
pin "date-fns/isPast", to: "https://ga.jspm.io/npm:date-fns@3.6.0/isPast.mjs"
pin "date-fns/toDate", to: "https://ga.jspm.io/npm:date-fns@3.6.0/toDate.mjs"
pin "mitt", to: "https://ga.jspm.io/npm:mitt@3.0.1/dist/mitt.mjs"
