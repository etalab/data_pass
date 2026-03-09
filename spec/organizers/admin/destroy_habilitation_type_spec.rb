RSpec.describe Admin::DestroyHabilitationType, type: :organizer do
  describe '.call' do
    subject(:organizer) { described_class.call(admin:, habilitation_type:) }

    let(:admin) { create(:user, :admin) }
    let(:habilitation_type) { create(:habilitation_type) }

    before { habilitation_type }

    it { is_expected.to be_success }

    it 'deletes the HabilitationType' do
      expect { organizer }.to change(HabilitationType, :count).by(-1)
    end

    it 'creates an admin event' do
      expect { organizer }.to change(AdminEvent, :count).by(1)
      expect(AdminEvent.last.name).to eq('habilitation_type_destroyed')
    end
  end
end
