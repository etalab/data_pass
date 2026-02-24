RSpec.describe Habilitation::OriginHeaderInfo, type: :component do
  let(:authorization_request) { create(:authorization_request, :api_entreprise) }

  context 'with form_uid and approving instructor' do
    subject { render_inline(component) }

    let(:authorization) { create(:authorization, request: authorization_request, form_uid: 'api-entreprise') }
    let(:component) { described_class.new(authorization: authorization) }
    let!(:event) { create(:authorization_request_event, entity: authorization, name: 'approve', authorization_request: authorization_request) }

    it 'renders the form name and instructor email' do
      expect(subject).to have_content('créée par la')
      expect(subject).to have_content('formulaire')
      expect(subject).to have_content('validée par')
      expect(subject).to have_content(event.user.email)
    end
  end

  context 'with form_uid but no approving instructor' do
    subject { render_inline(component) }

    let(:authorization) { create(:authorization, request: authorization_request, form_uid: 'api-entreprise') }
    let(:component) { described_class.new(authorization: authorization) }

    it 'renders the form name without instructor' do
      expect(subject).to have_content('créée par la')
      expect(subject).to have_content('formulaire')
      expect(subject).to have_no_content('validée par')
    end
  end

  context 'without form_uid but with approving instructor' do
    subject { render_inline(component) }

    let(:authorization) { create(:authorization, request: authorization_request, form_uid: nil) }
    let(:component) { described_class.new(authorization: authorization) }
    let!(:event) { create(:authorization_request_event, entity: authorization, name: 'approve', authorization_request: authorization_request) }

    it 'renders without form name but with instructor' do
      expect(subject).to have_content('liée à la')
      expect(subject).to have_content('validée par')
      expect(subject).to have_no_content('formulaire')
    end
  end

  context 'without form_uid and without approving instructor' do
    subject { render_inline(component) }

    let(:authorization) { create(:authorization, request: authorization_request, form_uid: nil) }
    let(:component) { described_class.new(authorization: authorization) }

    it 'renders without form name and without instructor' do
      expect(subject).to have_content('liée à la')
      expect(subject).to have_no_content('validée par')
      expect(subject).to have_no_content('formulaire')
    end
  end

  context 'when auto-generated with form_uid' do
    subject { render_inline(component) }

    let(:parent) { create(:authorization, request: authorization_request) }
    let(:authorization) { create(:authorization, request: authorization_request, parent_authorization: parent, form_uid: 'api-entreprise') }
    let(:component) { described_class.new(authorization: authorization) }

    it 'renders auto-generated message with form name' do
      expect(subject).to have_content('automatiquement délivrée')
      expect(subject).to have_content('formulaire')
    end
  end

  context 'when auto-generated with form_uid and approving instructor on parent' do
    subject { render_inline(component) }

    let(:parent) { create(:authorization, request: authorization_request) }
    let(:authorization) { create(:authorization, request: authorization_request, parent_authorization: parent, form_uid: 'api-entreprise') }
    let(:component) { described_class.new(authorization: authorization) }
    let!(:event) { create(:authorization_request_event, entity: parent, name: 'approve', authorization_request: authorization_request) }

    it 'renders auto-generated message with form name and parent instructor' do
      expect(subject).to have_content('automatiquement délivrée')
      expect(subject).to have_content('formulaire')
      expect(subject).to have_content('validée par')
      expect(subject).to have_content(event.user.email)
    end
  end

  context 'when auto-generated without form_uid but with approving instructor on parent' do
    subject { render_inline(component) }

    let(:parent) { create(:authorization, request: authorization_request) }
    let(:authorization) { create(:authorization, request: authorization_request, parent_authorization: parent, form_uid: nil) }
    let(:component) { described_class.new(authorization: authorization) }
    let!(:event) { create(:authorization_request_event, entity: parent, name: 'approve', authorization_request: authorization_request) }

    it 'renders auto-generated message with parent instructor but without form name' do
      expect(subject).to have_content('automatiquement délivrée')
      expect(subject).to have_no_content('formulaire')
      expect(subject).to have_content('validée par')
      expect(subject).to have_content(event.user.email)
    end
  end

  context 'when auto-generated without form_uid' do
    subject { render_inline(component) }

    let(:parent) { create(:authorization, request: authorization_request) }
    let(:authorization) { create(:authorization, request: authorization_request, parent_authorization: parent, form_uid: nil) }
    let(:component) { described_class.new(authorization: authorization) }

    it 'renders auto-generated message without form name' do
      expect(subject).to have_content('automatiquement délivrée')
      expect(subject).to have_no_content('formulaire')
    end
  end
end
