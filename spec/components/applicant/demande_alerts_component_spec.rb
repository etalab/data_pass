RSpec.describe Applicant::DemandeAlertsComponent, type: :component do
  let(:authorization_request) { create(:authorization_request, :api_entreprise, state:) }
  let(:current_user) { authorization_request.applicant }
  let(:state) { :draft }
  let(:authorization) { nil }
  let(:component) { described_class.new(authorization_request:, current_user:, authorization:) }

  describe 'rendering' do
    context 'when user is only in contacts' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft) }
      let(:current_user) { create(:user) }

      before do
        authorization_request.update!(contact_technique_email: current_user.email)
        render_inline(component)
      end

      it 'renders the contact mention alert' do
        expect(page).to have_css('.fr-alert.fr-alert--info')
        expect(page).to have_content(I18n.t('demandes_habilitations.current_user_mentions_alert.text', contact_types: 'contact technique'))
      end
    end

    context 'when authorization request is changes_requested' do
      let(:state) { :changes_requested }

      before { render_inline(component) }

      it 'renders the instructor banner' do
        expect(page).to have_css('.fr-notice.fr-notice--warning')
      end

      it 'renders the changes requested title' do
        expect(page).to have_content(I18n.t('authorization_requests.show.changes_requested.title'))
      end
    end

    context 'when authorization request is refused' do
      let(:state) { :refused }

      before { render_inline(component) }

      it 'renders the instructor banner' do
        expect(page).to have_css('.fr-notice.fr-notice--alert')
      end

      it 'renders the refused title' do
        expect(page).to have_content(I18n.t('authorization_requests.show.refused.title'))
      end
    end

    context 'when dirty_from_v1' do
      let(:authorization_request) do
        create(:authorization_request, :api_entreprise, :draft_and_filled).tap do |ar|
          ar.update!(dirty_from_v1: true)
        end
      end

      before { render_inline(component) }

      it 'renders dirty from v1 alert' do
        expect(page).to have_css('.fr-alert.fr-alert--warning')
        expect(page).to have_content(I18n.t('authorization_requests.show.dirty_from_v1.title'))
      end
    end

    context 'when update is in progress' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :reopened) }
      let(:authorization) { authorization_request.latest_authorization }

      before { render_inline(component) }

      it 'renders the update in progress alert' do
        expect(page).to have_css('.fr-alert.fr-alert--info')
        expect(page).to have_content(I18n.t('authorization_request_forms.summary.reopening_alerts.update_in_progress.title'))
      end

      it 'renders the link to the authorization request' do
        expect(page).to have_link("Demande de mise à jour n°#{authorization_request.id}")
      end
    end

    context 'when draft and not reopening' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft) }

      before { render_inline(component) }

      it 'renders the summary before submit section' do
        expect(page).to have_css('h2.fr-h3', text: I18n.t('authorization_request_forms.summary.title'))
        expect(page).to have_content(ActionController::Base.helpers.strip_tags(I18n.t('authorization_request_forms.summary.description')))
      end
    end

    context 'when no alert conditions are met' do
      let(:state) { :submitted }

      it 'renders nothing' do
        render_inline(component)
        expect(page.text).to be_empty
      end
    end

    context 'when changes_requested during reopening' do
      let(:authorization_request) do
        create(:authorization_request, :api_entreprise, :reopened).tap do |ar|
          ar.update_columns(state: 'changes_requested')
        end
      end
      let!(:modification_request) do
        create(:instructor_modification_request, authorization_request:, reason: 'Modification requise')
      end

      before { render_inline(component) }

      it 'renders the reopening changes requested banner' do
        expect(page).to have_css('.fr-notice.fr-notice--warning')
        expect(page).to have_content(I18n.t('authorization_requests.show.reopening_changes_requested.title'))
      end
    end

    context 'when refused during reopening' do
      let(:authorization_request) do
        create(:authorization_request, :api_entreprise, :reopened).tap do |ar|
          ar.update_columns(state: 'refused')
        end
      end
      let!(:denial) do
        create(:denial_of_authorization, authorization_request:, reason: 'Refus de mise à jour')
      end

      before { render_inline(component) }

      it 'renders the reopening refused banner' do
        expect(page).to have_css('.fr-notice.fr-notice--alert')
        expect(page).to have_content(I18n.t('authorization_requests.show.reopening_refused.title'))
      end
    end
  end
end
