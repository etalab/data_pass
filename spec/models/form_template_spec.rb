require 'rails_helper'

RSpec.describe FormTemplate do
  let(:habilitation_type) do
    ht = create(:habilitation_type)
    ht.form_templates.delete_all
    ht
  end

  describe 'creation' do
    it 'persists with habilitation_type and name' do
      template = described_class.create!(habilitation_type:, name: 'Mon Template')

      expect(template).to be_persisted
      expect(template.slug).to be_present
    end
  end

  describe 'slug' do
    it 'is auto-generated from name via friendly_id' do
      template = described_class.create!(habilitation_type:, name: 'Mon Template Super')

      expect(template.slug).to eq('mon-template-super')
    end

    it 'is unique' do
      described_class.create!(habilitation_type:, name: 'Identique')
      duplicate = described_class.new(habilitation_type:, name: 'Autre nom', slug: 'identique')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to be_present
    end

    it 'is refused if it collides with a YAML form uid' do
      yaml_uid = AuthorizationRequestFormConfigurations.instance.all.keys.first.to_s
      template = described_class.new(habilitation_type:, name: 'Conflit', slug: yaml_uid)

      expect(template).not_to be_valid
      expect(template.errors[:slug]).to be_present
    end
  end

  describe 'default invariant' do
    it 'cannot be flipped from true to false when it is the only default' do
      default_template = described_class.create!(habilitation_type:, name: 'Default', default: true)
      described_class.create!(habilitation_type:, name: 'Other', default: false)

      default_template.default = false

      expect(default_template.save).to be(false)
      expect(default_template.errors[:default]).to be_present
    end

    it 'can be flipped to false when another default exists' do
      default_a = described_class.create!(habilitation_type:, name: 'A', default: true)
      described_class.create!(habilitation_type:, name: 'B', default: true)

      default_a.default = false

      expect(default_a.save).to be(true)
    end
  end

  describe '#destroy' do
    it 'is forbidden when destroying the last default of a habilitation_type' do
      default_template = described_class.create!(habilitation_type:, name: 'Default', default: true)
      described_class.create!(habilitation_type:, name: 'Other', default: false)

      expect(default_template.destroy).to be(false)
      expect(default_template.errors[:base]).to be_present
      expect { default_template.reload }.not_to raise_error
    end

    it 'is allowed for a non-default template' do
      described_class.create!(habilitation_type:, name: 'Default', default: true)
      other = described_class.create!(habilitation_type:, name: 'Other', default: false)

      expect { other.destroy }.to change(described_class, :count).by(-1)
    end

    it 'is allowed for a default template when another default exists' do
      default_a = described_class.create!(habilitation_type:, name: 'A', default: true)
      described_class.create!(habilitation_type:, name: 'B', default: true)

      expect { default_a.destroy }.to change(described_class, :count).by(-1)
    end
  end

  describe '#service_provider' do
    it 'returns nil when no service_provider_id is set' do
      template = described_class.create!(habilitation_type:, name: 'No SP')

      expect(template.service_provider).to be_nil
    end

    it 'resolves the ServiceProvider from the YAML backend when set' do
      sp_id = ServiceProvider.all.first.id
      template = described_class.create!(habilitation_type:, name: 'With SP', service_provider_id: sp_id)

      expect(template.service_provider).to eq(ServiceProvider.find(sp_id))
    end

    it 'returns nil when the service_provider_id does not match any YAML entry' do
      template = described_class.create!(habilitation_type:, name: 'Bad SP', service_provider_id: 'inexistant')

      expect(template.service_provider).to be_nil
    end
  end

  describe 'paper_trail' do
    it 'tracks a version on update' do
      template = described_class.create!(habilitation_type:, name: 'Versionné')

      expect { template.update!(description: 'nouvelle description') }
        .to change { template.versions.count }.by(1)
    end
  end

  describe 'AuthorizationRequestForm cache invalidation' do
    before { AuthorizationRequestForm.reset! }

    after { AuthorizationRequestForm.reset! }

    it 'exposes a freshly created FormTemplate to the façade without manual reset' do
      AuthorizationRequestForm.all

      template = described_class.create!(habilitation_type:, name: 'Frais')

      expect(AuthorizationRequestForm.all.map(&:uid)).to include(template.slug)
    end

    it 'removes a destroyed FormTemplate from the façade without manual reset' do
      described_class.create!(habilitation_type:, name: 'Default conservé', default: true)
      removable = described_class.create!(habilitation_type:, name: 'À jeter', default: false)
      AuthorizationRequestForm.all

      removable.destroy!

      expect(AuthorizationRequestForm.all.map(&:uid)).not_to include(removable.slug)
    end
  end
end
