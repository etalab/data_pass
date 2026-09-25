namespace :db_seed do
  desc 'Seeds database in sandbox'

  task sandbox: :environment do
    puts '[db_seed:sandbox] ignoré sur sandbox/recette : la base est conservée pour la recette'
  end
end
