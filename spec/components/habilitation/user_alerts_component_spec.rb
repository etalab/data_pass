RSpec.describe Habilitation::UserAlertsComponent, type: :component do
  let(:authorization) { create(:authorization_request, :api_entreprise, :validated).latest_authorization }
  let(:current_user) { authorization.request.applicant }
  let(:component) { described_class.new(authorization:, current_user:) }

  describe 'rendering' do
    context 'when update is in progress' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :reopened) }
      let(:authorization) { authorization_request.latest_authorization }

      before { render_inline(component) }

      it 'renders the update in progress notice with title' do
        expect(page).to have_css('.fr-notice.fr-notice--info.fr-notice--full-width')
        expect(page).to have_content(I18n.t('authorization_request_forms.summary.reopening_alerts.update_in_progress.title'))
      end

      it 'renders the link to the authorization request' do
        expect(page).to have_link("Consulter la demande de mise à jour n°#{authorization_request.id}", href: "/demandes/#{authorization_request.id}")
      end
    end

    context 'when access callout should be displayed' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }
      let(:authorization) { authorization_request.latest_authorization }

      before { render_inline(component) }

      it 'renders the access callout with title and content' do
        expect(page).to have_css('.fr-callout')
        expect(page).to have_content(I18n.t('authorization_requests.show.access_callout.title'))
        expect(page).to have_content(authorization_request.name)
      end

      it 'renders the access link button with external link icon' do
        expect(page).to have_link(
          I18n.t('authorization_requests.show.access_callout.button'),
          href: authorization_request.access_link
        )
        expect(page).to have_css('.fr-btn.fr-btn--icon-right.fr-icon-external-link-line')
      end

      it 'opens link in new tab' do
        expect(page).to have_css('a[target="_blank"]')
      end
    end

    context 'when user is not applicant' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }
      let(:authorization) { authorization_request.latest_authorization }
      let(:current_user) { create(:user) }

      before { render_inline(component) }

      it 'does not render access callout' do
        expect(page).to have_no_css('.fr-callout')
      end
    end

    context 'when authorization request has no access_link' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }
      let(:authorization) { authorization_request.latest_authorization }

      before { render_inline(component) }

      it 'does not render access callout' do
        expect(page).to have_no_css('.fr-callout')
      end
    end

    context 'when no alerts should be displayed' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }
      let(:authorization) { authorization_request.latest_authorization }

      it 'renders nothing' do
        render_inline(component)
        expect(page).to have_no_css('.fr-notice')
        expect(page).to have_no_css('.fr-callout')
      end

      it 'does not render component' do
        expect(component.render?).to be false
      end
    end
  end
end
