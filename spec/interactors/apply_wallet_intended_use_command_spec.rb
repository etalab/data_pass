RSpec.describe ApplyWalletIntendedUseCommand do
  subject(:result) { described_class.call(authorization_request:, command:) }

  let(:authorization_request) { create(:authorization_request, :registre_wallet, fill_all_attributes: true) }
  let(:use) { authorization_request.active_wallet_intended_uses.sole }
  let(:pid) { WalletRegistry::Rulebook.available.find_by!(identifier: 'pid') }
  let(:mdl) { WalletRegistry::Rulebook.available.find_by!(identifier: 'mdl') }

  context 'with « add_use »' do
    let(:command) { 'add_use' }

    it 'builds a use, opens it and focuses its name' do
      expect(result).to be_success
      expect(authorization_request.active_wallet_intended_uses.size).to eq(2)
      expect(result.opened_use).to be_new_record
      expect(result.focus).to eq('name')
    end
  end

  context 'with « remove_use »' do
    let(:command) { "remove_use:#{use.id}" }

    it 'marks the use for removal and focuses the add button' do
      expect(result).to be_success
      expect(use).to be_marked_for_destruction
      expect(result.focus).to eq('add_use')
    end
  end

  context 'with « add_attestation » on a known use' do
    let(:command) { "add_attestation:#{use.id}:#{pid.id}" }

    it 'adds the attestation and focuses it' do
      expect(result).to be_success
      expect(use.attestations.map(&:rulebook)).to eq([mdl, pid])
      expect([result.opened_use, result.focus]).to eq([use, "attestation_#{pid.id}"])
    end
  end

  context 'with « add_attestation » of a retired rulebook' do
    let(:command) { "add_attestation:#{use.id}:#{pid.id}" }

    before { pid.update!(retired_at: Time.current) }

    it { is_expected.to be_failure }
  end

  context 'with « remove_attestation »' do
    let(:command) { "remove_attestation:#{use.id}:#{mdl.id}" }

    it 'marks the attestation for removal and focuses the add button of the use' do
      expect(result).to be_success
      expect(use.attestations).to be_empty
      expect(result.focus).to eq('add_attestation')
    end
  end

  context 'with « open_catalog »' do
    let(:command) { "open_catalog:#{use.id}" }

    it 'remembers the use whose catalog opens' do
      expect(result.catalog_use).to eq(use)
    end
  end

  context 'with a command on a use of another request' do
    let(:other_use) { create(:authorization_request, :registre_wallet, fill_all_attributes: true).wallet_intended_uses.sole }
    let(:command) { "remove_use:#{other_use.id}" }

    it { is_expected.to be_failure }
  end

  context 'with an unknown command' do
    let(:command) { "reset:#{use.id}" }

    it { is_expected.to be_failure }
  end
end
