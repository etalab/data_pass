RSpec.configure do |config|
  config.before(:suite) do
    WalletRegistry::RulebookSources::ManualReading.import!
  end
end
