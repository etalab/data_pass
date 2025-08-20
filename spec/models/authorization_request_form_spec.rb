RSpec.describe AuthorizationRequestForm do
  describe '.all' do
    it 'returns a list of all authorizations forms' do
      expect(described_class.all).to be_all { |a| a.is_a? AuthorizationRequestForm }
    end
  end

  describe '#prefilled?' do
    subject(:prefilled?) { form.prefilled? }

    context 'when the form is prefilled' do
      let(:form) { described_class.find('api-entreprise-mgdis') }

      it { is_expected.to be true }
    end

    context 'when the form is not prefilled' do
      let(:form) { described_class.find('api-entreprise') }

      it { is_expected.to be false }
    end
  end

  describe '#stage' do
    subject(:stage) { form.stage }

    context 'when stage is defined' do
      let(:form) { described_class.find('api-impot-particulier-cantine-scolaire-production') }

      it { is_expected.to be_a AuthorizationRequestForm::Stage }

      it 'has the correct definition' do
        expect(stage.definition).to eq(form.authorization_definition)
      end

      it 'has the correct previous_form_uid' do
        expect(stage.previous_form_uid).to eq('api-impot-particulier-cantine-scolaire-sandbox')
      end
    end

    context 'when stage is not defined' do
      context 'when definition has no multiple stages' do
        let(:form) { described_class.find('api-entreprise') }

        it { is_expected.to be_nil }
      end

      context 'when definition has multiple stages' do
        context 'when definition has previous stages' do
          let(:form) { described_class.find('api-hermes-production') }

          it { is_expected.to be_a AuthorizationRequestForm::Stage }

          it 'has the correct definition' do
            expect(stage.definition).to eq(form.authorization_definition)
          end

          it 'has the correct previous_form_uid' do
            expect(stage.previous_form_uid).to eq('api-hermes-sandbox')
          end
        end

        context 'when definition has no previous stages' do
          let(:form) { described_class.find('api-hermes-sandbox') }

          it { is_expected.to be_a AuthorizationRequestForm::Stage }

          it 'has the correct definition' do
            expect(stage.definition).to eq(form.authorization_definition)
          end

          it 'has no previous_form_uid' do
            expect(stage.previous_form_uid).to be_nil
          end
        end
      end
    end
  end

  describe '#active_authorization_requests_for' do
    subject(:active_requests) { form.active_authorization_requests_for(organization) }

    let(:form) { described_class.find('hubee-cert-dc') }
    let(:organization) { create(:organization) }

    context 'when organization has no authorization requests' do
      it { is_expected.to be_empty }
    end

    context 'when organization has authorization requests in different states' do
      let!(:draft_request) { create(:authorization_request, :hubee_cert_dc, :draft, organization:) }
      let!(:submitted_request) { create(:authorization_request, :hubee_cert_dc, :submitted, organization:) }
      let!(:validated_request) { create(:authorization_request, :hubee_cert_dc, :validated, organization:) }
      let!(:refused_request) { create(:authorization_request, :hubee_cert_dc, :refused, organization:) }
      let!(:archived_request) { create(:authorization_request, :hubee_cert_dc, :archived, organization:) }

      it 'includes active requests but excludes archived and refused requests' do
        expect(active_requests).to include(draft_request, submitted_request, validated_request)
        expect(active_requests).not_to include(archived_request, refused_request)
      end
    end

    context 'when organization has validated request with revoked authorization' do
      let!(:validated_request) { create(:authorization_request, :hubee_cert_dc, :validated, organization:) }
      let!(:revoked_authorization) { create(:authorization, request: validated_request, state: 'revoked', organization:) }

      it 'excludes requests that have only revoked authorizations' do
        expect(active_requests).not_to include(validated_request)
      end
    end

    context 'when organization has validated request with both active and revoked authorizations' do
      let!(:validated_request) { create(:authorization_request, :hubee_cert_dc, :validated, organization:) }
      let!(:active_authorization) { create(:authorization, request: validated_request, state: 'active', organization:) }
      let!(:revoked_authorization) { create(:authorization, request: validated_request, state: 'revoked', organization:) }

      it 'includes requests that have at least one non-revoked authorization' do
        expect(active_requests).to include(validated_request)
      end
    end
  end
end
