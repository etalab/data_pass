RSpec.describe Admin::DestroyHabilitationTypeRecord do
  subject(:interactor) { described_class.call(habilitation_type:) }

  let!(:habilitation_type) { create(:habilitation_type) }

  it 'destroys the habilitation type' do
    expect { interactor }.to change(HabilitationType, :count).by(-1)
  end
end
