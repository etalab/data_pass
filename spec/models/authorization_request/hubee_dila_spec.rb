RSpec.describe AuthorizationRequest::HubEEDila do
  describe 'scope unicity across authorization requests' do
    subject { build(:authorization_request, :hubee_dila, scopes:, organization:) }

    let(:organization) { create(:organization) }
    let(:scopes) { %w[etat_civil depot_dossier_pacs recensement_citoyen] }

    context 'when there is no other authorization request with same scopes' do
      it { is_expected.to be_valid }
    end

    context 'when there is another authorization request with same scopes' do
      context 'when it is not the same organization' do
        let!(:other_authorization_request) { create(:authorization_request, :hubee_dila, scopes: scopes) }

        it { is_expected.to be_valid }
      end

      context 'when it is the same organization' do
        context 'when there is scopes overlap' do
          let!(:other_authorization_request) { create(:authorization_request, :hubee_dila, scopes: scopes.sample(1), organization: subject.organization) }

          it { is_expected.not_to be_valid }

          context 'when authorization request is archived' do
            let!(:other_authorization_request) { create(:authorization_request, :hubee_dila, :archived, scopes: scopes.sample(1), organization: subject.organization) }

            it { is_expected.to be_valid }
          end
        end

        context 'when there is no scopes overlap' do
          let!(:other_authorization_request) { create(:authorization_request, :hubee_dila, scopes: %w[hebergement_tourisme], organization: subject.organization) }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
