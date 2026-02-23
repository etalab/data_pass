RSpec.describe DynamicAuthorizationTypeRegistrar do
  DynamicRecord = Struct.new(:uid, :blocks, :contact_types)

  let(:uid) { 'test_dynamic_api' }

  before do
    stub_const("AuthorizationRequest::#{uid.classify}", Class.new(AuthorizationRequest))
  end

  describe '.register' do
    subject(:register) { described_class.register(record) }

    context 'with basic_infos block' do
      let(:record) { DynamicRecord.new(uid, %w[basic_infos], []) }

      it 'registers a class accessible via const_get' do
        register
        expect(AuthorizationRequest.const_get(uid.classify)).to be < AuthorizationRequest
      end

      it 'sets the correct STI type name' do
        register
        expect(AuthorizationRequest.const_get(uid.classify).name).to eq("AuthorizationRequest::#{uid.classify}")
      end

      it 'adds intitule and description accessors' do
        register
        demande = AuthorizationRequest.const_get(uid.classify).new
        demande.intitule = 'Projet Test'
        demande.description = 'Ma description'
        expect(demande.data).to include('intitule' => 'Projet Test', 'description' => 'Ma description')
      end
    end

    context 'with cadre_juridique block' do
      let(:record) { DynamicRecord.new(uid, %w[cadre_juridique], []) }

      it 'adds cadre_juridique_url accessor' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.extra_attributes).to include(:cadre_juridique_url)
      end
    end

    context 'with personal_data block' do
      let(:record) { DynamicRecord.new(uid, %w[personal_data], []) }

      it 'adds personal_data attributes' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.extra_attributes).to include(:destinataire_donnees_caractere_personnel)
      end
    end

    context 'with scopes block' do
      let(:record) { DynamicRecord.new(uid, %w[scopes], []) }

      it 'enables scopes on the class' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.scopes_enabled?).to be(true)
      end
    end

    context 'with contacts block' do
      let(:record) { DynamicRecord.new(uid, %w[contacts], %i[contact_metier contact_technique]) }

      it 'registers the contact kinds on the class' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.contact_types).to eq(%i[contact_metier contact_technique])
      end
    end

    context 'with multiple blocks' do
      let(:record) { DynamicRecord.new(uid, %w[basic_infos cadre_juridique], []) }

      it 'applies all blocks' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.extra_attributes).to include(:intitule, :cadre_juridique_url)
      end
    end

    context 'with an unknown block' do
      let(:record) { DynamicRecord.new(uid, %w[unknown_block], []) }

      it 'silently ignores it' do
        expect { register }.not_to raise_error
      end
    end

    context 'when called twice with the same uid' do
      let(:record) { DynamicRecord.new(uid, %w[basic_infos], []) }

      it 'is idempotent — no error on re-registration' do
        expect {
          described_class.register(record)
          described_class.register(record)
        }.not_to raise_error
      end

      it 'returns the latest class after re-registration' do
        described_class.register(record)
        first_klass = AuthorizationRequest.const_get(uid.classify)

        described_class.register(record)
        second_klass = AuthorizationRequest.const_get(uid.classify)

        expect(second_klass).not_to equal(first_klass)
      end
    end
  end
end
