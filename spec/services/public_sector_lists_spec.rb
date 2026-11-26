RSpec.describe PublicSectorLists do
  subject(:lists) { described_class.instance }

  it 'loads the public legal categories copied from ProConnect' do
    expect(lists.legal_categories).to include('7210', '4110')
  end

  it 'loads the SIRENs that are always public and those that never are' do
    expect(lists.always_public_sirens).to include('784523318')
    expect(lists.never_public_sirens).to include('348679010')
  end

  it 'keeps the source of the copy' do
    expect(lists.source).to include('repository' => 'https://github.com/proconnect-gouv/proconnect-identite')
  end

  it 'cannot be modified' do
    expect { lists.legal_categories << '5710' }.to raise_error(FrozenError)
  end
end
