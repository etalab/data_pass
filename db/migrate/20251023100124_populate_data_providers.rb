class PopulateDataProviders < ActiveRecord::Migration[8.0]
  def up
    Seeds.new.create_data_providers
  end

  def down
    DataProvider.delete_all
  end
end
