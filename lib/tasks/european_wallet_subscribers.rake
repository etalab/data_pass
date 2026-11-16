namespace :european_wallet do
  namespace :subscribers do
    desc 'Exporte en CSV les inscrits « Être prévenu » d’un profil (organization, intermediary, attestation_provider)'
    task :export, [:profile] => :environment do |_task, args|
      puts EuropeanWalletSubscribersExport.new(profile: args.fetch(:profile)).to_csv
    end

    desc 'Supprime les inscrits « Être prévenu » d’un profil, après l’annonce de l’ouverture de son parcours'
    task :purge, [:profile] => :environment do |_task, args|
      count = EuropeanWalletSubscribersPurge.new(profile: args.fetch(:profile)).call
      puts "#{count} inscrit(s) supprimé(s) pour le profil #{args[:profile]}"
    end
  end
end
