RSpec.describe AuthorizationHeaderComponent, type: :component do
  let(:authorization) { create(:authorization) }
  let(:authorization_request) { authorization.request }

  describe 'header information' do
    subject { render_inline(described_class.new(authorization: authorization, authorization_request: authorization_request)) }

    it 'renders the authorization header with correct information' do
      expect(subject.css('h1').text).to include("Habilitation à #{authorization.definition.name}")
      expect(subject.css('p').text).to include(authorization.name)
      expect(subject.css('.fr-badge').text).to include("Habilitation n°#{authorization.id}")
      expect(subject.css('.fr-badge').text).to include(authorization.state)
    end
  end

  describe 'action buttons for different states' do
    context 'when authorization is active' do
      subject { render_inline(described_class.new(authorization: active_authorization, authorization_request: active_authorization.request)) }

      let(:active_authorization) { create(:authorization) }

      before do
        active_authorization.state = 'active'
        active_authorization.revoked = false
      end

      it 'should have an action container even if policy does not allow actions' do
        expect(subject.css('.authorization-request-form-header__actions')).to be_present
      end
    end

    context 'when authorization is revoked' do
      subject { render_inline(described_class.new(authorization: revoked_authorization, authorization_request: revoked_authorization.request)) }

      let(:revoked_authorization) { create(:authorization) }

      before do
        revoked_authorization.revoked = true
      end

      it 'shows a contact support button with mailto link' do
        expect(subject.css('.authorization-request-form-header__actions a[href="mailto:datapass@api.gouv.fr"]')).to be_present
      end
    end

    context 'when authorization is obsolete' do
      subject { render_inline(described_class.new(authorization: obsolete_authorization, authorization_request: obsolete_authorization.request)) }

      let(:obsolete_authorization) { create(:authorization) }

      before do
        obsolete_authorization.state = 'obsolete'
      end

      it 'does not show any action buttons' do
        expect(subject.css('.authorization-request-form-header__actions .fr-btn')).to be_empty
      end
    end

    context 'when policy allows start_next_stage' do
      subject { render_inline(described_class.new(authorization: sandbox_authorization, authorization_request: sandbox_request)) }

      let(:sandbox_request) { create(:authorization_request, :api_impot_particulier_sandbox, :validated, fill_all_attributes: true) }
      let(:sandbox_authorization) { create(:authorization, request: sandbox_request, state: 'active') }

      it 'would display the start production button if policy allows' do
        # In a real integration test, this would work when the policy returns true
        expect(subject.css('#start-production-button')).to be_present
      end
    end
  end
end
