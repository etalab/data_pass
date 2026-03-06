RSpec.describe HabilitationType do
  subject(:habilitation_type) { build(:habilitation_type) }

  describe '#uid' do
    it 'returns the slug in snake_case' do
      habilitation_type.name = 'Mon API Test'
      habilitation_type.save!
      expect(habilitation_type.uid).to eq('mon_api_test')
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
  end

  describe '#public, #unique, #startable_by_applicant' do
    it 'returns fixed values' do
      expect(habilitation_type.public).to be(true)
      expect(habilitation_type.unique).to be(false)
      expect(habilitation_type.startable_by_applicant).to be(true)
    end
  end

  describe 'slug collision with YAML' do
    it 'is invalid when uid matches an existing YAML definition' do
      existing_yaml_uid = AuthorizationDefinition.yaml_records.first.id
      habilitation_type.name = existing_yaml_uid.tr('_', ' ')

      habilitation_type.save

      expect(habilitation_type.errors[:slug]).to be_present
    end
  end

  describe 'callbacks on create' do
    it 'calls DynamicAuthorizationRequestRegistrar' do
      expect(DynamicAuthorizationRequestRegistrar).to receive(:call).with(instance_of(described_class))
      habilitation_type.save!
    end

    it 'resets AuthorizationDefinition cache' do
      expect(AuthorizationDefinition).to receive(:reset!)
      habilitation_type.save!
    end

    it 'resets AuthorizationRequestForm cache' do
      expect(AuthorizationRequestForm).to receive(:reset!)
      habilitation_type.save!
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

    context 'when authorization requests exist for this type' do
      before do
        type_class_name = "AuthorizationRequest::#{habilitation_type.uid.classify}"
        allow(AuthorizationRequest).to receive(:where).with(type: type_class_name).and_return(double(count: 1))
      end

      it 'prevents destroy' do
        expect { habilitation_type.destroy }.not_to change(described_class, :count)
      end

      it 'adds an error on base' do
        habilitation_type.destroy
        expect(habilitation_type.errors[:base]).to be_present
      end
    end
  end
end
