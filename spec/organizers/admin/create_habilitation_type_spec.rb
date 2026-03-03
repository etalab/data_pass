RSpec.describe Admin::CreateHabilitationType, type: :organizer do
  describe '.call' do
    subject(:organizer) { described_class.call(admin:, params:) }

    let(:admin) { create(:user, :admin) }
    let(:data_provider) { create(:data_provider) }
    let(:params) do
      {
        name: 'API Test',
        kind: 'api',
        data_provider_id: data_provider.id,
        blocks: %w[basic_infos legal],
      }
    end

    it { is_expected.to be_success }

    it 'creates a HabilitationType' do
      expect { organizer }.to change(HabilitationType, :count).by(1)
    end

    it 'creates an admin event' do
      expect { organizer }.to change(AdminEvent, :count).by(1)
      expect(AdminEvent.last.name).to eq('habilitation_type_created')
    end

    context 'when params are invalid' do
      let(:params) { { name: '', kind: 'api', data_provider_id: data_provider.id } }

      it { is_expected.not_to be_success }

      it 'does not create a HabilitationType' do
        expect { organizer }.not_to change(HabilitationType, :count)
      end
    end
  end
end
