RSpec.describe PublicSectorLists do
  subject(:lists) { described_class.instance }

  it 'loads the public legal categories copied from ProConnect' do
    expect(lists.legal_categories).to include('7210', '4110')
  end

  it 'loads the whitelisted and blacklisted SIRENs' do
    expect(lists.whitelisted_sirens).to include('784523318')
    expect(lists.blacklisted_sirens).to include('348679010')
  end

  it 'keeps the source of the copy' do
    expect(lists.source).to include('repository' => 'https://github.com/proconnect-gouv/proconnect-identite')
  end

  it 'cannot be modified' do
    expect { lists.legal_categories << '5710' }.to raise_error(FrozenError)
  end
end
