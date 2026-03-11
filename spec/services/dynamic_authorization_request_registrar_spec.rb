RSpec.describe DynamicAuthorizationRequestRegistrar do
  let(:record_class) { Struct.new(:uid, :blocks, :contact_types) }
  let(:uid) { 'test_dynamic_api' }

  before do
    stub_const("AuthorizationRequest::#{uid.classify}", Class.new(AuthorizationRequest))
  end

  describe '.call' do
    subject(:register) { described_class.call(record) }

    context 'with basic_infos block' do
      let(:record) { record_class.new(uid, [{ 'name' => 'basic_infos' }], []) }

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

    context 'with legal block' do
      let(:record) { record_class.new(uid, [{ 'name' => 'legal' }], []) }

      it 'adds cadre_juridique_url accessor' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.extra_attributes).to include(:cadre_juridique_url)
      end

      context 'when submitted' do
        let(:habilitation_type) { create(:habilitation_type, blocks: [{ 'name' => 'legal' }]) }
        let(:klass) { AuthorizationRequest.const_get(habilitation_type.uid.classify) }

        it 'is invalid without document nor url' do
          demande = klass.new
          demande.valid?(:submit)
          expect(demande.errors[:cadre_juridique_document]).to be_present
          expect(demande.errors[:cadre_juridique_url]).to be_present
        end

        it 'is valid with a document attached' do
          demande = klass.new
          File.open('spec/fixtures/dummy.pdf') do |file|
            demande.cadre_juridique_document.attach(io: file, filename: 'dummy.pdf')
          end
          demande.valid?(:submit)
          expect(demande.errors[:cadre_juridique_document]).to be_empty
          expect(demande.errors[:cadre_juridique_url]).to be_empty
        end

        it 'is valid with a url' do
          demande = klass.new(cadre_juridique_url: 'https://example.gouv.fr/loi')
          demande.valid?(:submit)
          expect(demande.errors[:cadre_juridique_document]).to be_empty
          expect(demande.errors[:cadre_juridique_url]).to be_empty
        end
      end
    end

    context 'with personal_data block' do
      let(:record) { record_class.new(uid, [{ 'name' => 'personal_data' }], []) }

      it 'adds personal_data attributes' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.extra_attributes).to include(:destinataire_donnees_caractere_personnel)
      end
    end

    context 'with scopes block' do
      let(:record) { record_class.new(uid, [{ 'name' => 'scopes' }], []) }

      it 'enables scopes on the class' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.scopes_enabled?).to be(true)
      end
    end

    context 'with contacts block' do
      let(:record) { record_class.new(uid, [{ 'name' => 'contacts' }], %i[contact_metier contact_technique]) }

      it 'registers the contact kinds on the class' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.contact_types).to eq(%i[contact_metier contact_technique])
      end
    end

    context 'with multiple blocks' do
      let(:record) { record_class.new(uid, [{ 'name' => 'basic_infos' }, { 'name' => 'legal' }], []) }

      it 'applies all blocks' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.extra_attributes).to include(:intitule, :cadre_juridique_url)
      end
    end

    context 'with blocks stored as strings' do
      let(:record) { record_class.new(uid, %w[basic_infos legal], []) }

      it 'applies all blocks' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.extra_attributes).to include(:intitule, :cadre_juridique_url)
      end
    end

    context 'with an unknown block' do
      let(:record) { record_class.new(uid, [{ 'name' => 'unknown_block' }], []) }

      it 'does not raise' do
        expect { register }.not_to raise_error
      end

      it 'logs a warning' do
        expect(Rails.logger).to receive(:warn).with(/unknown block 'unknown_block'/)
        register
      end
    end

    context 'with an invalid uid' do
      let(:record) { record_class.new('123 invalid!', [{ 'name' => 'basic_infos' }], []) }

      it 'does not raise' do
        expect { register }.not_to raise_error
      end

      it 'logs an error' do
        expect(Rails.logger).to receive(:error).with(/invalid uid '123 invalid!'/)
        register
      end
    end

    context 'when called twice with the same uid' do
      let(:record) { record_class.new(uid, [{ 'name' => 'basic_infos' }], []) }

      it 'is idempotent — no error on re-registration' do
        expect {
          described_class.call(record)
          described_class.call(record)
        }.not_to raise_error
      end

      it 'returns the latest class after re-registration' do
        described_class.call(record)
        first_klass = AuthorizationRequest.const_get(uid.classify)

        described_class.call(record)
        second_klass = AuthorizationRequest.const_get(uid.classify)

        expect(second_klass).not_to equal(first_klass)
      end
    end
  end
end
