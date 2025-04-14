RSpec.describe AuthorizationHeaderComponent, type: :component do
  let(:auth_policy) { instance_double(AuthorizationPolicy, reopen?: true, transfer?: false, start_next_stage?: false, show_contact_support?: false) }
  let(:instruction_policy) { instance_double(Instruction::AuthorizationRequestPolicy, show?: false) }

  let(:authorization) { create(:authorization) }
  let(:authorization_request) do
    instance_double(AuthorizationRequest,
      id: 123,
      latest_authorization: authorization,
      name: 'Test Authorization Request',)
  end

  let(:helpers_stub) do
    double('Helpers').tap do |helpers|
      allow(helpers).to receive(:policy) do |record|
        if record.is_a?(Array) && record.first == :instruction
          instruction_policy
        else
          auth_policy
        end
      end

      allow(helpers).to receive(:t, &:to_s)
      allow(helpers).to receive(:link_to) { |text, _path, _opts = {}| text }
      allow(helpers).to receive(:dsfr_main_modal_button) { |*args| args.first }
      allow(helpers).to receive_messages(url_for: '/mocked/path', new_authorization_request_transfer_path: '/mocked/transfer/path', next_authorization_request_stage_path: '/mocked/next/stage/path', render: '')
    end
  end

  let(:component) do
    component = described_class.new(authorization: authorization, current_user: authorization.applicant)
    allow(component).to receive(:helpers).and_return(helpers_stub)
    component
  end

  before do
    allow(authorization).to receive(:request).and_return(authorization_request)
  end

  context 'when rendering the component' do
    subject { render_inline(component) }

    it 'renders correctly without error' do
      expect(subject).to have_css('.fr-badge')
    end

    it 'renders the authorization header with correct information' do
      expect(subject.css('h1').text).to include("Habilitation à #{authorization.definition.name}")
      expect(subject.css('p').text).to include(authorization.name.to_s)
      expect(subject.css('.fr-badge').text).to include("Habilitation n°#{authorization.id}")
      expect(subject.css('.fr-badge').text).to include(authorization.state)
    end
  end

  describe 'badge styling' do
    context 'when authorization is active' do
      subject { render_inline(component) }

      before do
        authorization.state = 'active'
        authorization.revoked = false
      end

      it 'shows a success badge' do
        expect(subject.css('.fr-badge--success')).to be_present
      end
    end

    context 'when authorization is revoked' do
      subject { render_inline(component) }

      before do
        authorization.state = 'revoked'
        authorization.revoked = true
      end

      it 'shows an error badge' do
        expect(subject.css('.fr-badge--error')).to be_present
      end
    end

    context 'when authorization is obsolete' do
      subject { render_inline(component) }

      before do
        authorization.state = 'obsolete'
      end

      it 'shows a plain badge' do
        badge = subject.css('.fr-badge').last
        expect(badge['class']).not_to include('fr-badge--success')
        expect(badge['class']).not_to include('fr-badge--error')
      end
    end
  end
end
