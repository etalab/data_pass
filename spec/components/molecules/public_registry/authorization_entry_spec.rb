RSpec.describe Molecules::PublicRegistry::AuthorizationEntry do
  let(:required_values) do
    { number: 'H44120', denomination: 'Ville de Clamart', service: 'APIParticulier', provider: 'DINUM', validated_on: Date.new(2026, 7, 2) }
  end

  it 'leaves the fiche-only values empty when the list does not need them' do
    entry = described_class.new(**required_values)

    expect([entry.siret, entry.scopes, entry.legal_basis]).to eq([nil, [], nil])
  end

  it 'turns missing scopes into an empty list' do
    expect(described_class.new(**required_values, scopes: nil).scopes).to eq([])
  end

  it 'requires the values shown on the tile' do
    expect { described_class.new(number: 'H44120') }.to raise_error(ArgumentError, /missing keyword/)
  end
end
