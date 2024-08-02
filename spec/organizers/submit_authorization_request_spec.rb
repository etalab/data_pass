RSpec.describe SubmitAuthorizationRequest do
  describe '.call' do
    subject(:submit_authorization_request) { described_class.call(user: authorization_request.applicant, authorization_request:, authorization_request_params:) }

    let(:authorization_request_params) { nil }

    context 'with authorization request in draft state' do
      context 'with valid authorization request' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

        it { is_expected.to be_success }

        it 'changes state to submitted' do
          expect { submit_authorization_request }.to change { authorization_request.reload.state }.from('draft').to('submitted')
        end

        it 'changes last_submitted_at to now' do
          expect { submit_authorization_request }.to change { authorization_request.reload.last_submitted_at }.to(be_within(1.second).of(Time.current))
        end

        include_examples 'creates an event', event_name: :submit

        describe 'versions diffing' do
          let(:authorization_request_params) do
            ActionController::Parameters.new(intitule: 'new intitule')
          end

          it 'creates a changelog' do
            expect { submit_authorization_request }.to change { authorization_request.changelogs.count }.by(1)
          end

          describe 'on first submit' do
            context 'when there is no default data on form' do
              it 'stores the initial diff with all data' do
                submit_authorization_request
                changelog = authorization_request.changelogs.last

                expect(changelog.diff).to eq(
                  authorization_request.data.to_h { |k, _| [k, [nil, authorization_request.public_send(k)]] }
                )
              end
            end

            context 'when there is default data on form and a change on one of this data' do
              let(:authorization_request) { create(:authorization_request, :api_entreprise_mgdis, :draft, fill_all_attributes: true) }
              let(:authorization_request_params) { ActionController::Parameters.new(intitule: 'new intitule') }
              let!(:original_intitule) { authorization_request.intitule }

              it 'stores the diff for this data only' do
                submit_authorization_request
                changelog = authorization_request.changelogs.last

                expect(changelog.diff['intitule']).to eq(
                  [original_intitule, 'new intitule']
                )

                expect(changelog.diff.except('intitule', 'scopes')).to eq(
                  authorization_request.data.except('intitule', 'scopes').to_h { |k, _| [k, [nil, authorization_request.public_send(k)]] }
                )
              end
            end
          end

          context 'when it is not the first submit and there is a changelog' do
            before do
              create(:authorization_request_changelog, authorization_request:)
            end

            it 'stories only the diff on the field' do
              old_intitule = authorization_request.intitule

              submit_authorization_request
              changelog = authorization_request.changelogs.last

              expect(changelog.diff).to eq({
                'intitule' => [old_intitule, 'new intitule']
              })
            end
          end

          describe 'with scopes changes' do
            let(:authorization_request_params) do
              ActionController::Parameters.new(
                scopes: authorization_request.scopes + %w[scope1 scope2]
              )
            end
            let!(:initial_scopes) { authorization_request.scopes.dup }

            let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

            describe 'on first submit' do
              it 'stores the scopes diff as an array' do
                submit_authorization_request

                changelog = authorization_request.changelogs.last

                expect(changelog.diff['scopes']).to eq([
                  nil,
                  initial_scopes + %w[scope1 scope2]
                ])
              end
            end

            describe 'when it is not the first submit and there is a changelog' do
              let!(:previous_authorization_request_changelog) do
                create(:authorization_request_changelog, authorization_request:)
              end

              it 'stores the diff on the scopes field' do
                submit_authorization_request

                changelog = authorization_request.changelogs.last

                expect(changelog.diff['scopes']).to eq([
                  initial_scopes,
                  initial_scopes + %w[scope1 scope2]
                ])
              end

              context 'when changelog has attributes no longer present on the model' do
                let!(:previous_authorization_request_changelog) do
                  create(:authorization_request_changelog, authorization_request:, diff: { 'old_attribute' => [nil, 'whatever'] })
                end

                it 'does not raise an error by ignoring attribute within diff building' do
                  expect { submit_authorization_request }.not_to raise_error
                end
              end
            end
          end

          it 'notifies the instructors' do
            expect { submit_authorization_request }.to have_enqueued_mail(Instruction::AuthorizationRequestMailer, :submitted)
          end
        end
      end

      context 'with invalid params' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

        let(:authorization_request_params) { ActionController::Parameters.new(intitule: '') }

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { submit_authorization_request }.not_to change { authorization_request.reload.state }
        end

        it 'does not create an event' do
          expect { submit_authorization_request }.not_to change { authorization_request.events.count }
        end

        it 'does not updates params' do
          expect { submit_authorization_request }.not_to change { authorization_request.reload.intitule }
        end
      end

      context 'with missing checkbox' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

        before do
          authorization_request.update!(terms_of_service_accepted: false)
        end

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { submit_authorization_request }.not_to change { authorization_request.reload.state }
        end

        it 'does not create an event' do
          expect { submit_authorization_request }.not_to change { authorization_request.events.count }
        end

        it 'does not updates params' do
          expect { submit_authorization_request }.not_to change { authorization_request.reload.intitule }
        end
      end

      context 'with invalid authorization request' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft) }

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { submit_authorization_request }.not_to change { authorization_request.reload.state }
        end

        it 'does not create an event' do
          expect { submit_authorization_request }.not_to change { authorization_request.events.count }
        end
      end
    end

    context 'with authorization request in validated state' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

      it { is_expected.to be_a_failure }

      it 'does not create an event' do
        expect { submit_authorization_request }.not_to change { authorization_request.events.count }
      end
    end

    describe 'non-regression test: changelog creation after empty changelog' do
      let!(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, scopes:) }
      let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }
      let(:scopes) do
        %w[open_data_unites_legales_etablissements_insee]
      end
      let(:authorization_request_params) { ActionController::Parameters.new(scopes: scopes + %w[unites_legales_etablissements_insee]) }
      let(:create_empty_changelog) do
        CreateAuthorizationRequestChangelog.call(authorization_request:)
      end

      before do
        create_empty_changelog

        RequestChangesOnAuthorizationRequest.call(
          authorization_request: authorization_request.reload,
          user: authorization_request.applicant,
          instructor_modification_request_params: {
            reason: 'Be better please'
          }
        )
      end

      it 'creates a changelog with diff too' do
        expect { submit_authorization_request }.to change(authorization_request.changelogs, :count).by(1)

        changelog = authorization_request.changelogs.last

        expect(changelog.diff).to be_blank
      end
    end
  end
end
