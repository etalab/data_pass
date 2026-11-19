class LoadWalletRegistryManualReading < ActiveRecord::Migration[8.1]
  def up
    WalletRegistry::RulebookSources::ManualReading.import!
  end

  def down; end
end
