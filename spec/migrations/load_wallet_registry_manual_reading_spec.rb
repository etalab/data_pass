require 'rails_helper'
require Rails.root.join('db/migrate/20261117100002_load_wallet_registry_manual_reading.rb')

RSpec.describe LoadWalletRegistryManualReading do
  def migrate_up
    ActiveRecord::Migration.suppress_messages { described_class.new.migrate(:up) }
  end

  def catalog
    WalletRegistry::Rulebook.available.order(:identifier).pluck(:identifier, :version)
  end

  it 'remet en service le relevé manuel quand le catalogue n’en propose aucun' do
    WalletRegistry::Rulebook.available.find_each { |rulebook| rulebook.update!(retired_at: Time.current) }

    expect { migrate_up }.to change { catalog }.from([]).to([%w[mdl ARF-3.02], %w[pid 1.7]])
  end

  it 'ne duplique rien quand le catalogue est déjà chargé' do
    expect { migrate_up }.not_to(change { [WalletRegistry::Rulebook.count, WalletRegistry::RulebookClaim.count] })
  end
end
