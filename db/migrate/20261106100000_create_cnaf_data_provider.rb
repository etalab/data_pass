class CreateCnafDataProvider < ActiveRecord::Migration[8.1]
  def up
    DataProvider.find_or_create_by!(slug: 'cnaf') do |provider|
      provider.name = 'Caisse nationale des allocations familiales (CNAF)'
      provider.link = 'https://www.caf.fr'
    end
  end

  def down
    DataProvider.where(slug: 'cnaf').find_each { |provider| provider.destroy if provider.deletable? }
  end
end
