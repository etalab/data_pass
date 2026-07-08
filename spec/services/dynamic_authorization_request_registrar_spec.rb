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
        subject(:valid?) { demande.valid?(:submit) }

        let(:habilitation_type) { create(:habilitation_type, blocks: [{ 'name' => 'legal' }]) }
        let(:klass) { AuthorizationRequest.const_get(habilitation_type.uid.classify) }
        let(:demande) { klass.new(**params) }
        let(:params) { {} }

        before { valid? }

        context 'without document nor url' do
          it { expect(demande.errors[:cadre_juridique_document]).to be_present }
          it { expect(demande.errors[:cadre_juridique_url]).to be_present }
        end

        context 'with a document attached' do
          let(:demande) do
            klass.new.tap do |d|
              File.open('spec/fixtures/dummy.pdf') do |file|
                d.cadre_juridique_document.attach(io: file, filename: 'dummy.pdf')
              end
            end
          end

          it { expect(demande.errors[:cadre_juridique_document]).to be_empty }
          it { expect(demande.errors[:cadre_juridique_url]).to be_empty }
        end

        context 'with a url' do
          let(:params) { { cadre_juridique_url: 'https://example.gouv.fr/loi' } }

          it { expect(demande.errors[:cadre_juridique_document]).to be_empty }
          it { expect(demande.errors[:cadre_juridique_url]).to be_empty }
        end
      end
    end

    context 'with legal_dinum block' do
      let(:record) { record_class.new(uid, [{ 'name' => 'legal_dinum' }], []) }

      it 'adds cadre_juridique_dinum_url accessor' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.extra_attributes).to include(:cadre_juridique_dinum_url)
      end

      context 'when submitted' do
        subject(:valid?) { demande.valid?(:submit) }

        let(:habilitation_type) { create(:habilitation_type, blocks: [{ 'name' => 'legal_dinum' }]) }
        let(:klass) { AuthorizationRequest.const_get(habilitation_type.uid.classify) }
        let(:demande) { klass.new(**params) }
        let(:params) { {} }

        before { valid? }

        context 'without document nor url' do
          it { expect(demande.errors[:cadre_juridique_dinum_document]).to be_present }
          it { expect(demande.errors[:cadre_juridique_dinum_url]).to be_present }
        end

        context 'with a document attached' do
          let(:demande) do
            klass.new.tap do |d|
              File.open('spec/fixtures/dummy.pdf') do |file|
                d.cadre_juridique_dinum_document.attach(io: file, filename: 'dummy.pdf')
              end
            end
          end

          it { expect(demande.errors[:cadre_juridique_dinum_document]).to be_empty }
          it { expect(demande.errors[:cadre_juridique_dinum_url]).to be_empty }
        end

        context 'with a url' do
          let(:params) { { cadre_juridique_dinum_url: 'https://example.gouv.fr/loi' } }

          it { expect(demande.errors[:cadre_juridique_dinum_document]).to be_empty }
          it { expect(demande.errors[:cadre_juridique_dinum_url]).to be_empty }
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

      context 'when submitted' do
        subject(:valid?) { demande.valid?(:submit) }

        let(:habilitation_type) { create(:habilitation_type, blocks: [{ 'name' => 'personal_data' }]) }
        let(:klass) { AuthorizationRequest.const_get(habilitation_type.uid.classify) }
        let(:demande) { klass.new(**params) }
        let(:params) { {} }

        before { valid? }

        context 'when duree_conservation > 36 months without justification' do
          let(:params) { { duree_conservation_donnees_caractere_personnel: 37, duree_conservation_donnees_caractere_personnel_justification: nil } }

          it { expect(demande.errors[:duree_conservation_donnees_caractere_personnel_justification]).to be_present }
        end

        context 'when duree_conservation <= 36 months' do
          let(:params) { { duree_conservation_donnees_caractere_personnel: 36, duree_conservation_donnees_caractere_personnel_justification: nil } }

          it { expect(demande.errors[:duree_conservation_donnees_caractere_personnel_justification]).to be_empty }
        end

        context 'when duree_conservation > 36 months with justification' do
          let(:params) { { duree_conservation_donnees_caractere_personnel: 37, duree_conservation_donnees_caractere_personnel_justification: 'Raison valable' } }

          it { expect(demande.errors[:duree_conservation_donnees_caractere_personnel_justification]).to be_empty }
        end
      end
    end

    context 'with cnous_data_extraction_criteria block' do
      let(:record) { record_class.new(uid, [{ 'name' => 'cnous_data_extraction_criteria' }], []) }

      it 'adds cnous_data_extraction_criteria attributes' do
        register
        klass = AuthorizationRequest.const_get(uid.classify)
        expect(klass.extra_attributes).to include(
          :manual_code_insee_communes,
          :echelon_bourse,
          :premiere_date_transmission,
        )
      end

      context 'when submitted' do
        subject(:valid?) { demande.valid?(:submit) }

        let(:habilitation_type) { create(:habilitation_type, blocks: [{ 'name' => 'cnous_data_extraction_criteria' }]) }
        let(:klass) { AuthorizationRequest.const_get(habilitation_type.uid.classify) }
        let(:demande) { klass.new(**params) }
        let(:params) { {} }

        let(:known_communes) { %w[75056 69123] }

        before do
          known_communes.each do |code|
            stub_request(:get, "https://geo.api.gouv.fr/communes/#{code}?fields=nom,codeDepartement,codeRegion")
              .to_return(
                status: 200,
                body: { 'code' => code, 'nom' => 'X', 'codeDepartement' => '75', 'codeRegion' => '11' }.to_json,
                headers: { 'Content-Type' => 'application/json' }
              )
          end
          stub_request(:get, %r{https://geo\.api\.gouv\.fr/communes/(?!(#{known_communes.join('|')})\?)})
            .to_return(status: 404, body: '')

          valid?
        end

        context 'without any field' do
          it { expect(demande.errors[:manual_code_insee_communes]).to be_present }
          it { expect(demande.errors[:echelon_bourse]).to be_present }
          it { expect(demande.errors[:premiere_date_transmission]).to be_present }
        end

        context 'with all fields filled correctly' do
          let(:params) do
            {
              manual_code_insee_communes: %w[75056 69123],
              echelon_bourse: '5',
              premiere_date_transmission: 1.month.from_now.to_date.iso8601,
            }
          end

          it { expect(demande.errors[:manual_code_insee_communes]).to be_empty }
          it { expect(demande.errors[:echelon_bourse]).to be_empty }
          it { expect(demande.errors[:premiere_date_transmission]).to be_empty }
        end

        context 'with an invalid echelon_bourse value' do
          let(:params) { { echelon_bourse: 'XX' } }

          it { expect(demande.errors[:echelon_bourse]).to be_present }
        end

        context 'with the 0Bis echelon_bourse value (CNOUS API casing)' do
          let(:params) { { echelon_bourse: '0Bis' } }

          it { expect(demande.errors[:echelon_bourse]).to be_empty }
        end

        context 'with a malformed code INSEE in the communes list' do
          let(:params) { { manual_code_insee_communes: %w[75056 ABCDE] } }

          it { expect(demande.errors[:manual_code_insee_communes]).to be_present }

          it 'identifies the faulty chip by its position' do
            expect(demande.errors[:manual_code_insee_communes].join).to include('n°2', 'ABCDE')
          end
        end

        context 'with a well-formatted but unknown code INSEE' do
          let(:params) { { manual_code_insee_communes: %w[75056 99999] } }

          it { expect(demande.errors[:manual_code_insee_communes]).to be_present }

          it 'identifies the faulty chip by its position' do
            expect(demande.errors[:manual_code_insee_communes].join).to include('n°2', '99999')
          end
        end

        context 'with duplicate codes INSEE' do
          let(:params) { { manual_code_insee_communes: %w[75056 75056] } }

          it { expect(demande.manual_code_insee_communes).to eq(%w[75056]) }
        end

        context 'with a premiere_date_transmission in the past' do
          let(:params) { { premiere_date_transmission: 1.day.ago.to_date.iso8601 } }

          it { expect(demande.errors[:premiere_date_transmission]).to be_present }
        end

        context 'with premiere_date_transmission set to today' do
          let(:params) { { premiere_date_transmission: Date.current.iso8601 } }

          it { expect(demande.errors[:premiere_date_transmission]).to be_empty }
        end

        context 'with a premiere_date_transmission in the future' do
          let(:params) { { premiere_date_transmission: 1.month.from_now.to_date.iso8601 } }

          it { expect(demande.errors[:premiere_date_transmission]).to be_empty }
        end

        context 'with a non-parseable premiere_date_transmission' do
          let(:params) { { premiere_date_transmission: 'pas-une-date' } }

          it { expect(demande.errors[:premiere_date_transmission]).to be_present }
        end
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
