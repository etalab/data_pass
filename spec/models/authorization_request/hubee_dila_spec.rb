RSpec.describe AuthorizationRequest::HubEEDila do
  describe 'administrateur_metier_phone_number validation' do
    subject { build(:authorization_request, :hubee_dila, :submitted, administrateur_metier_phone_number: phone_number) }

    context 'with valid French phone numbers' do
      context 'with French format 0X XX XX XX XX' do
        let(:phone_number) { '06 12 34 56 78' }

        it { is_expected.to be_valid }
      end

      context 'with French format without spaces' do
        let(:phone_number) { '0612345678' }

        it { is_expected.to be_valid }
      end

      context 'with international format +33 X XX XX XX XX' do
        let(:phone_number) { '+33 6 12 34 56 78' }

        it { is_expected.to be_valid }
      end

      context 'with international format without spaces' do
        let(:phone_number) { '+33612345678' }

        it { is_expected.to be_valid }
      end

      context 'with dashes format' do
        let(:phone_number) { '06-66-93-20-74' }

        it { is_expected.to be_valid }
      end

      context 'with dots format' do
        let(:phone_number) { '06.66.87.34.56' }

        it { is_expected.to be_valid }
      end
    end

    context 'with invalid phone numbers' do
      context 'with incorrect format' do
        let(:phone_number) { '06/12/34/56/78' }

        it { is_expected.not_to be_valid }

        it 'has phone number format error' do
          subject.valid?
          expect(subject.errors[:administrateur_metier_phone_number]).to include(I18n.t('activemodel.errors.messages.invalid_french_phone_format'))
        end
      end

      context 'with foreign number' do
        let(:phone_number) { '+1 555 123 4567' }

        it { is_expected.not_to be_valid }
      end

      context 'with invalid length' do
        let(:phone_number) { '06 12 34 56 7' }

        it { is_expected.not_to be_valid }
      end
    end

    context 'when validation is not needed' do
      subject { build(:authorization_request, :hubee_dila, state: 'draft', administrateur_metier_phone_number: phone_number) }

      let(:phone_number) { 'invalid phone' }

      it { is_expected.to be_valid }
    end
  end

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
