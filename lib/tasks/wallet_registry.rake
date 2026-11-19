namespace :wallet_registry do
  desc 'Charge en base le relevé manuel des rulebooks (idempotent). Toute correction d’un rulebook change sa version : voir docs/technique/registre_wallet_referentiel_attestations.md'
  task load_manual_reading: :environment do
    WalletRegistry::RulebookSources::ManualReading.import!.each do |rulebook|
      puts "#{rulebook.identifier} #{rulebook.version} : #{rulebook.claims.size} données, #{rulebook.formats.size} format(s)"
    end
  end
end
