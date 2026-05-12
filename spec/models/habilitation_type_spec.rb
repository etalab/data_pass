RSpec.describe HabilitationType do
  subject(:habilitation_type) { build(:habilitation_type) }

  describe '#uid' do
    it 'returns the slug in snake_case with dyn suffix' do
      habilitation_type.name = 'Mon API Test'
      habilitation_type.save!
      expect(habilitation_type.uid).to eq('mon_api_test_dyn')
    end
  end

  describe '#should_generate_new_friendly_id?' do
    it 'generates slug with -dyn suffix on first save' do
      habilitation_type.save!
      expect(habilitation_type.slug).to be_present
      expect(habilitation_type.slug).to end_with('-dyn')
    end

    it 'does not change slug when name is updated after creation' do
      habilitation_type.save!
      original_slug = habilitation_type.slug
      habilitation_type.update!(name: 'Nouveau Nom Différent')
      expect(habilitation_type.reload.slug).to eq(original_slug)
    end
  end

  describe '#ordered_steps' do
    it 'returns blocks in BLOCK_ORDER regardless of storage order' do
      habilitation_type.blocks = [
        { 'name' => 'contacts' },
        { 'name' => 'basic_infos' },
        { 'name' => 'legal' },
      ]
      expect(habilitation_type.ordered_steps).to eq(%w[basic_infos legal contacts])
    end

    it 'excludes blocks not present' do
      habilitation_type.blocks = [{ 'name' => 'basic_infos' }]
      expect(habilitation_type.ordered_steps).to eq(%w[basic_infos])
    end

    it 'positions cnous_data_extraction_criteria between scopes and contacts' do
      habilitation_type.blocks = [
        { 'name' => 'contacts' },
        { 'name' => 'cnous_data_extraction_criteria' },
        { 'name' => 'scopes' },
      ]
      expect(habilitation_type.ordered_steps).to eq(%w[scopes cnous_data_extraction_criteria contacts])
    end
  end

  describe '#public, #unique, #startable_by_applicant' do
    it 'returns fixed values' do
      expect(habilitation_type.public).to be(true)
      expect(habilitation_type.unique).to be(false)
      expect(habilitation_type.startable_by_applicant).to be(true)
    end
  end

  describe '#normalize_friendly_id' do
    it 'appends -dyn suffix to the slug' do
      habilitation_type.name = 'Mon API Test'
      habilitation_type.save!
      expect(habilitation_type.slug).to eq('mon-api-test-dyn')
    end

    it 'allows names ending with a pluralizable word' do
      habilitation_type.name = 'Mon API scopes'
      expect(habilitation_type).to be_valid
      habilitation_type.save!
      expect(habilitation_type.slug).to eq('mon-api-scopes-dyn')
    end
  end

  describe 'uid classifiability validation' do
    it 'is invalid when name starts with a digit' do
      habilitation_type.name = '1er portail'
      expect(habilitation_type).not_to be_valid
      expect(habilitation_type.errors[:name]).to be_present
    end

    it 'is valid when name generates a classify-stable uid' do
      habilitation_type.name = 'Mon API'
      expect(habilitation_type).to be_valid
    end
  end

  describe 'validation: contacts block requires contact_types' do
    context 'when contacts block is selected' do
      before { habilitation_type.blocks = [{ 'name' => 'contacts' }] }

      it 'is invalid without contact_types' do
        habilitation_type.contact_types = []
        expect(habilitation_type).not_to be_valid
        expect(habilitation_type.errors[:contact_types]).to be_present
      end

      it 'is valid with contact_types' do
        habilitation_type.contact_types = ['contact_technique']
        expect(habilitation_type).to be_valid
      end
    end

    context 'when contacts block is not selected' do
      before { habilitation_type.blocks = [{ 'name' => 'basic_infos' }] }

      it 'is valid without contact_types' do
        habilitation_type.contact_types = []
        expect(habilitation_type).to be_valid
      end

      it 'is valid with contact_types' do
        habilitation_type.contact_types = ['contact_technique']
        expect(habilitation_type).to be_valid
      end
    end
  end

  describe 'validation: scopes block requires scopes' do
    context 'when scopes block is selected' do
      before { habilitation_type.blocks = [{ 'name' => 'scopes' }] }

      it 'is invalid without scopes' do
        habilitation_type.scopes = []
        expect(habilitation_type).not_to be_valid
        expect(habilitation_type.errors[:scopes]).to be_present
      end

      it 'is valid with scopes' do
        habilitation_type.scopes = [{ 'name' => 'test', 'value' => 'test', 'group' => 'group' }]
        expect(habilitation_type).to be_valid
      end

      it 'is invalid when a scope has a blank name' do
        habilitation_type.scopes = [{ 'name' => '', 'value' => 'rfr', 'group' => 'Revenus' }]
        expect(habilitation_type).not_to be_valid
        expect(habilitation_type.errors.where(:scopes, :scope_name_blank, index: 0)).to be_present
      end

      it 'is invalid when a scope has a blank value' do
        habilitation_type.scopes = [{ 'name' => 'Revenu fiscal', 'value' => '', 'group' => 'Revenus' }]
        expect(habilitation_type).not_to be_valid
        expect(habilitation_type.errors.where(:scopes, :scope_value_blank, index: 0)).to be_present
      end

      it 'is valid when a scope has a blank group' do
        habilitation_type.scopes = [{ 'name' => 'Revenu fiscal', 'value' => 'rfr', 'group' => '' }]
        expect(habilitation_type).to be_valid
      end

      it 'validates each scope independently' do
        habilitation_type.scopes = [
          { 'name' => 'Valid', 'value' => 'valid', 'group' => '' },
          { 'name' => '', 'value' => '', 'group' => '' },
        ]
        expect(habilitation_type).not_to be_valid
        expect(habilitation_type.errors.where(:scopes, :scope_name_blank, index: 0)).to be_empty
        expect(habilitation_type.errors.where(:scopes, :scope_name_blank, index: 1)).to be_present
        expect(habilitation_type.errors.where(:scopes, :scope_value_blank, index: 1)).to be_present
      end

      it 'is invalid when two scopes have the same value' do
        habilitation_type.scopes = [
          { 'name' => 'Revenu fiscal', 'value' => 'rfr', 'group' => 'Revenus' },
          { 'name' => 'Autre revenu', 'value' => 'rfr', 'group' => 'Revenus' },
        ]
        expect(habilitation_type).not_to be_valid
        expect(habilitation_type.errors.where(:scopes, :scope_value_duplicate, index: 0)).to be_empty
        expect(habilitation_type.errors.where(:scopes, :scope_value_duplicate, index: 1)).to be_present
      end
    end

    context 'when scopes block is not selected' do
      before { habilitation_type.blocks = [{ 'name' => 'basic_infos' }] }

      it 'is valid without scopes' do
        habilitation_type.scopes = []
        expect(habilitation_type).to be_valid
      end
    end
  end

  describe 'versioning' do
    it 'creates a version on create' do
      expect { habilitation_type.save! }.to change { PaperTrail::Version.where(item_type: 'HabilitationType').count }.by(1)
    end

    it 'creates a version on update' do
      habilitation_type.save!
      expect { habilitation_type.update!(name: 'Nouveau Nom') }.to change(PaperTrail::Version, :count).by(1)
    end

    it 'creates a version on destroy' do
      habilitation_type.save!
      expect { habilitation_type.destroy! }.to change(PaperTrail::Version, :count).by(1)
    end

    it 'tracks attribute changes as a Hash in object_changes' do
      habilitation_type.save!
      habilitation_type.update!(name: 'Nouveau Nom')

      version = habilitation_type.versions.last
      expect(version.object_changes).to be_a(Hash)
      expect(version.object_changes['name'].last).to eq('Nouveau Nom')
    end
  end

  describe 'slug collision with YAML' do
    it 'does not collide with YAML definitions thanks to -dyn suffix' do
      existing_yaml_uid = AuthorizationDefinition.yaml_records.first.id
      habilitation_type.name = existing_yaml_uid.tr('_', ' ')

      expect(habilitation_type).to be_valid
      expect(habilitation_type.slug).to end_with('-dyn')
    end
  end

  describe 'callbacks on create' do
    it 'calls DynamicAuthorizationRequestRegistrar' do
      expect(DynamicAuthorizationRequestRegistrar).to receive(:call).with(instance_of(described_class))
      habilitation_type.save!
    end

    it 'resets AuthorizationDefinition cache' do
      expect(AuthorizationDefinition).to receive(:reset!).at_least(:once)
      habilitation_type.save!
    end

    it 'resets AuthorizationRequestForm cache' do
      expect(AuthorizationRequestForm).to receive(:reset!).at_least(:once)
      habilitation_type.save!
    end

    it 'generates User notification methods for the new type' do
      habilitation_type.save!
      user = build(:user)
      expect(user).to respond_to(:"instruction_submit_notifications_for_#{habilitation_type.uid}")
    end
  end

  describe 'validation on destroy' do
    let!(:record) { create(:habilitation_type) }

    context 'when no authorization requests exist' do
      it 'allows destroy' do
        expect { record.destroy }.to change(described_class, :count).by(-1)
      end
    end

    context 'when authorization requests exist for this type' do
      before do
        allow(record).to receive(:authorization_requests_count).and_return(1)
      end

      it 'prevents destroy' do
        expect { record.destroy }.not_to change(described_class, :count)
      end

      it 'adds an error on base' do
        record.destroy
        expect(record.errors[:base]).to be_present
      end
    end
  end

  describe 'callbacks on destroy' do
    before { habilitation_type.save! }

    it 'resets AuthorizationDefinition cache' do
      expect(AuthorizationDefinition).to receive(:reset!)
      habilitation_type.destroy!
    end

    it 'resets AuthorizationRequestForm cache' do
      expect(AuthorizationRequestForm).to receive(:reset!)
      habilitation_type.destroy!
    end

    it 'unregisters the dynamic class' do
      class_name = habilitation_type.uid.classify
      expect(AuthorizationRequest.const_defined?(class_name, false)).to be(true)
      habilitation_type.destroy!
      expect(AuthorizationRequest.const_defined?(class_name, false)).to be(false)
    end
  end
end
