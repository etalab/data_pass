RSpec.describe Admin::DestroyDataProviderRecord do
  subject(:interactor) { described_class.call(data_provider:) }

  let!(:data_provider) { create(:data_provider) }

  it 'destroys the data provider' do
    expect { interactor }.to change(DataProvider, :count).by(-1)
  end
end
