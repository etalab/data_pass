RSpec.describe AuthorizationHeaderComponent, type: :component do
  let(:authorization) { create(:authorization) }

  describe 'header information' do
    subject { render_inline(described_class.new(authorization: authorization, current_user: authorization.applicant)) }

    it 'renders the authorization header with correct information' do
      expect(subject.css('h1').text).to include("Habilitation à #{authorization.definition.name}")
      expect(subject.css('p').text).to include(authorization.name)
      expect(subject.css('.fr-badge').text).to include("Habilitation n°#{authorization.id}")
      expect(subject.css('.fr-badge').text).to include(authorization.state)
    end
  end

  describe 'badge styling' do
    context 'when authorization is active' do
      subject { render_inline(described_class.new(authorization: active_authorization, current_user: active_authorization.applicant)) }

      let(:active_authorization) { create(:authorization) }

      before do
        active_authorization.state = 'active'
        active_authorization.revoked = false
      end

      it 'shows a success badge' do
        expect(subject.css('.fr-badge--success')).to be_present
      end
    end

    context 'when authorization is revoked' do
      subject { render_inline(described_class.new(authorization: revoked_authorization, current_user: revoked_authorization.applicant)) }

      let(:revoked_authorization) { create(:authorization) }

      before do
        revoked_authorization.revoked = true
      end

      it 'shows an error badge' do
        expect(subject.css('.fr-badge--error')).to be_present
      end
    end

    context 'when authorization is obsolete' do
      subject { render_inline(described_class.new(authorization: obsolete_authorization, current_user: obsolete_authorization.applicant)) }

      let(:obsolete_authorization) { create(:authorization) }

      before do
        obsolete_authorization.state = 'obsolete'
      end

      it 'shows a plain badge' do
        badge = subject.css('.fr-badge').last
        expect(badge['class']).not_to include('fr-badge--success')
        expect(badge['class']).not_to include('fr-badge--error')
      end
    end
  end
end
