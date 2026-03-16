RSpec.describe Admin::UpdateHabilitationType, type: :organizer do
  describe '.call' do
    subject(:organizer) do
      described_class.call(admin:, habilitation_type:, params:)
    end

    let(:admin) { create(:user, :admin) }
    let(:habilitation_type) { create(:habilitation_type) }
    let(:params) { { name: 'Nouveau Nom', blocks: %w[basic_infos] } }

    it { is_expected.to be_success }

    it 'updates the attributes' do
      expect { organizer }
        .to change { habilitation_type.reload.name }
        .to('Nouveau Nom')
    end

    it 'creates an admin event' do
      expect { organizer }.to change(AdminEvent, :count).by(1)
      expect(AdminEvent.last.name).to eq('habilitation_type_updated')
    end

    it 'creates a PaperTrail version for the update' do
      habilitation_type
      expect { organizer }.to change(PaperTrail::Version, :count).by(1)
    end

    it 'records whodunnit when set' do
      PaperTrail.request.whodunnit = admin.id.to_s
      organizer
      version = habilitation_type.versions.last
      expect(version.whodunnit).to eq(admin.id.to_s)
    end
  end
end
