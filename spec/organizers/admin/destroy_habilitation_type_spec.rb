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

    context 'when users have roles linked to the habilitation type' do
      let!(:instructor) { create(:user, roles: ["#{habilitation_type.uid}:instructor", 'other_type:manager']) }

      it 'removes roles linked to the habilitation type' do
        organizer

        expect(instructor.reload.roles).to eq(['other_type:manager'])
      end
    end

    context 'when authorization requests exist for this type' do
      before do
        allow(habilitation_type).to receive(:authorization_requests_count).and_return(1)
      end

      it { is_expected.to be_failure }

      it 'does not destroy the habilitation type' do
        expect { organizer }.not_to change(HabilitationType, :count)
      end
    end
  end
end
