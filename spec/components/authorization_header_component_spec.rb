RSpec.describe AuthorizationHeaderComponent, type: :component do
  let(:auth_policy) { instance_double(AuthorizationPolicy, reopen?: true, transfer?: false, manual_transfer_from_instructor?: false, start_next_stage?: false, contact_support?: false) }
  let(:authorization) { create(:authorization) }
  let(:instruction_policy) { instance_double(Instruction::AuthorizationRequestPolicy, show?: false) }

  let(:authorization_request) do
    instance_double(AuthorizationRequest,
      id: 123,
      latest_authorization: authorization,
      name: 'Test Authorization Request',)
  end

  let(:component) do
    component = described_class.new(authorization: authorization, current_user: authorization.applicant)
    component
  end

  before do
    allow(authorization).to receive(:request).and_return(authorization_request)
    allow(component).to receive(:policy) do |record|
      if Array(record).first == :instruction
        instruction_policy
      else
        auth_policy
      end
    end
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
      expect(subject.css('.fr-badge').text).to include('Active')
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

      it 'shows an active translation text' do
        expect(subject.css('.fr-badge').text).to include('Active')
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

      it 'shows a revoked translation text' do
        expect(subject.css('.fr-badge').text).to include('Révoquée')
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

      it 'shows an obsolete translated text' do
        expect(subject.css('.fr-badge').text).to include('Obsolète')
      end
    end
  end

  describe 'styling based on authorization state' do
    describe '#header_background_class' do
      context 'when authorization is active' do
        before { authorization.state = 'active' }

        it 'returns blue background class' do
          expect(component.header_background_class).to eq('fr-background-action-high--blue-france')
        end
      end

      context 'when authorization is revoked' do
        before { authorization.state = 'revoked' }

        it 'returns grey background class' do
          expect(component.header_background_class).to eq('fr-background-alt--grey')
        end
      end

      context 'when authorization is obsolete' do
        before { authorization.state = 'obsolete' }

        it 'returns grey background class' do
          expect(component.header_background_class).to eq('fr-background-alt--grey')
        end
      end
    end

    describe '#header_text_class' do
      context 'when authorization is active' do
        before { authorization.state = 'active' }

        it 'returns inverted text class with active modifier' do
          expect(component.header_text_class).to eq('fr-text-inverted--blue-france')
        end
      end

      context 'when authorization is revoked' do
        before { authorization.state = 'revoked' }

        it 'returns mention grey text class with revoked modifier' do
          expect(component.header_text_class).to eq('fr-text-mention-grey')
        end
      end

      context 'when authorization is obsolete' do
        before { authorization.state = 'obsolete' }

        it 'returns mention grey text class with revoked modifier' do
          expect(component.header_text_class).to eq('fr-text-mention-grey')
        end
      end
    end
  end
end
