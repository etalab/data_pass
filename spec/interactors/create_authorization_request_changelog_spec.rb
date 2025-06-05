RSpec.describe CreateAuthorizationRequestChangelog, type: :interactor do
  describe 'changelog creation' do
    subject(:changelog) { described_class.call(authorization_request:).changelog }

    describe 'diff structure' do
      let!(:authorization_request) { create(:authorization_request, form_uid, fill_all_attributes: true) }

      context 'when it is the first changelog' do
        let(:form_uid) { :hubee_cert_dc }

        describe 'simple case, without prefilled attributes and nil values' do
          before do
            authorization_request.administrateur_metier_job_title = nil
            authorization_request.save!
          end

          it 'stores a diff for each attribute key, with first value being nil, and second value being the current value, including unchanged keys' do
            expect(changelog.diff).to eq(
              authorization_request.data.transform_values { |v| [nil, v] }.merge(
                'administrateur_metier_job_title' => [nil, nil]
              )
            )
          end
        end

        context 'with a form with prefilled data' do
          let(:form_uid) { :api_entreprise_mgdis }
          let(:authorization_request_form_data) { authorization_request.form.initialize_with.stringify_keys }

          describe 'not prefilled key' do
            it 'stores a diff this key, with first value being nil, and second value being the current value' do
              expect(changelog.diff['delegue_protection_donnees_email']).to eq([nil, authorization_request.delegue_protection_donnees_email])
            end
          end

          describe 'prefilled key' do
            context 'when there is a change on this specific field' do
              before do
                authorization_request.intitule = 'New intitule'
                authorization_request.save!
              end

              it 'stores a diff for this key, with first value being the prefilled value, and second value being the current value changed' do
                expect(changelog.diff['intitule']).to eq([authorization_request_form_data['intitule'], 'New intitule'])
              end
            end

            context 'when there is no change on this specific field' do
              it 'stores a diff for this key, with first and second values being the prefilled value' do
                expect(changelog.diff['intitule']).to eq([authorization_request_form_data['intitule'], authorization_request_form_data['intitule']])
              end
            end
          end
        end
      end

      context 'when it is not the first changelog' do
        let(:form_uid) { :api_entreprise_mgdis }

        let!(:old_intitule) { authorization_request.intitule }
        let!(:old_description) { authorization_request.description }

        describe 'second changelog' do
          before do
            described_class.call(authorization_request:)
          end

          context 'when there is a change between the last changelog and the current form data' do
            before do
              authorization_request.intitule = 'New intitule'
              authorization_request.description = 'New description'

              authorization_request.save!
            end

            it 'stores the diff between the last changelog and the current form data for these keys only' do
              expect(changelog.diff).to eq({
                'intitule' => [old_intitule, authorization_request.intitule],
                'description' => [old_description, authorization_request.description]
              })
            end
          end

          context 'when there is an old attribute present in changelog but no longer present in the authorization request' do
            before do
              latest_changelog = authorization_request.changelogs.last
              latest_changelog.diff['old'] = [nil, 'whatever']
              latest_changelog.save!
            end

            it 'does not store this key in the diff' do
              expect(changelog.diff).not_to have_key('old')
            end
          end
        end

        describe 'third changelog' do
          before do
            described_class.call(authorization_request:)

            authorization_request.intitule = 'New intitule'
            authorization_request.description = 'New description'

            described_class.call(authorization_request:)
          end

          context 'when there is a change on 1 key previously changed and 1 key not changed since first changelog' do
            before do
              authorization_request.intitule = 'New new intitule'
              authorization_request.duree_conservation_donnees_caractere_personnel = '12'

              authorization_request.save!
            end

            it 'store a diff for these 2 keys' do
              expect(changelog.diff).to eq({
                'intitule' => ['New intitule', 'New new intitule'],
                'duree_conservation_donnees_caractere_personnel' => [36, 12]
              })
            end
          end
        end

        describe 'when first changelog is not correctly created (legacy data)' do
          before do
            invalid_changelog = described_class.call(authorization_request:).changelog
            invalid_changelog.update!(diff: invalid_changelog.diff.except('intitule'))
          end

          context 'when there is an update on a missing key and another key' do
            before do
              authorization_request.intitule = 'New intitule'
              authorization_request.description = 'New description'
            end

            it 'stores a diff for the other key, not the missing one' do
              expect(changelog.diff).to eq({
                'description' => [old_description, authorization_request.description]
              })
            end
          end
        end
      end
    end

    describe 'attributes kind' do
      let(:create_changelog!) { described_class.call(authorization_request:) }

      describe 'document' do
        let!(:authorization_request) { create(:authorization_request, :api_entreprise_mgdis, fill_all_attributes: true) }

        let(:change_document_attribute!) do
          authorization_request.cadre_juridique_document.attach(io: File.open('spec/fixtures/another_dummy.pdf'), filename: 'another_document.pdf')
        end

        describe 'on first submit' do
          before do
            change_document_attribute!
          end

          it 'stores the name' do
            expect(changelog.diff['cadre_juridique_document']).to eq([nil, 'another_document.pdf'])
          end
        end

        describe 'on second submit' do
          before do
            create_changelog!
            change_document_attribute!
          end

          it 'stores the name' do
            expect(changelog.diff['cadre_juridique_document']).to eq([nil, 'another_document.pdf'])
          end
        end

        describe 'scopes' do
          let!(:authorization_request) { create(:authorization_request, :api_particulier, fill_all_attributes: true, scopes: %w[scope1 scope2]) }

          let(:change_scopes_attribute!) do
            authorization_request.scopes = %w[another_scope scope1]
            authorization_request.save!
          end

          describe 'on first submit' do
            before do
              change_scopes_attribute!
            end

            it 'stores the scopes' do
              expect(changelog.diff['scopes']).to eq([nil, %w[another_scope scope1]])
            end
          end

          describe 'on second submit' do
            before do
              create_changelog!
              change_scopes_attribute!
            end

            it 'stores the scopes' do
              expect(changelog.diff['scopes']).to eq([%w[scope1 scope2], %w[another_scope scope1]])
            end
          end
        end
      end
    end
  end
end
