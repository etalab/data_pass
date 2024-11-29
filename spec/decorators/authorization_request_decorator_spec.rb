RSpec.describe AuthorizationRequestDecorator, type: :decorator do
  describe '#prefilled_data?' do
    subject { authorization_request.decorate.prefilled_data?(keys) }

    let(:authorization_request) { create(:authorization_request, authorization_request_form, fill_all_attributes: true) }
    let(:keys) { authorization_request.data.keys }

    context 'with a simple authorization request which has no prefilled_data nor scopes on his config' do
      let(:authorization_request_form) { :hubee_cert_dc }

      it { is_expected.to be(false) }
    end

    context 'with an authorization request which has prefilled data' do
      let(:authorization_request_form) { :api_entreprise_mgdis }

      context 'when keys match prefilled data' do
        let(:keys) { %w[intitule] }

        it { is_expected.to be(true) }
      end

      context 'when keys do not match prefilled data' do
        let(:keys) { %w[responsable_traitement_email] }

        it { is_expected.to be(false) }
      end
    end

    describe 'with an authorization request which has scopes' do
      context 'when form has prefilled scopes' do
        let(:authorization_request_form) { :api_entreprise_mgdis }

        context 'when keys include scopes' do
          let(:keys) { %w[invalid scopes] }

          it { is_expected.to be(true) }
        end

        context 'when keys do not include scopes' do
          let(:keys) { %w[invalid] }

          it { is_expected.to be(false) }
        end
      end

      context 'when form has no prefilled scopes (non-regression test)' do
        let(:authorization_request_form) { :api_impot_particulier_production_avec_editeur }

        context 'when keys include scopes' do
          let(:keys) { %w[invalid scopes] }

          it { is_expected.to be(false) }
        end
      end
    end
  end
end
