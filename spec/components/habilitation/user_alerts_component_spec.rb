RSpec.describe Habilitation::UserAlertsComponent, type: :component do
  let(:authorization) { create(:authorization_request, :api_entreprise, :validated).latest_authorization }
  let(:current_user) { authorization.request.applicant }
  let(:component) { described_class.new(authorization:, current_user:) }

  describe 'rendering' do
    context 'when user is only in contacts' do
      let(:current_user) { create(:user) }
      let(:authorization_request) do
        create(:authorization_request, :api_entreprise, :draft_and_filled, contact_technique_email: current_user.email)
      end
      let(:authorization) do
        authorization_request.update!(state: 'submitted')
        create(:authorization, request: authorization_request, applicant: authorization_request.applicant, data: authorization_request.data)
      end

      before { render_inline(component) }

      it 'renders the contact mention alert' do
        expect(page).to have_css('.fr-alert.fr-alert--info')
        expect(page).to have_content(I18n.t('demandes_habilitations.current_user_mentions_alert.text', contact_types: 'contact technique'))
      end

      it 'does not render other alerts' do
        expect(page).to have_css('.fr-alert', count: 1)
        expect(page).to have_no_css('.fr-callout')
      end
    end

    context 'when update is in progress' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :reopened) }
      let(:authorization) { authorization_request.latest_authorization }

      before { render_inline(component) }

      it 'renders the update in progress alert with title' do
        expect(page).to have_css('.fr-alert.fr-alert--info')
        expect(page).to have_content(I18n.t('authorization_request_forms.summary.reopening_alerts.update_in_progress.title'))
      end

      it 'renders the link to the authorization request' do
        expect(page).to have_link("Demande de mise à jour n°#{authorization_request.id}", href: "/demandes/#{authorization_request.id}")
      end

      it 'does not render old version alert' do
        expect(page).to have_no_content(I18n.t('authorization_request_forms.summary.reopening_alerts.old_version.title'))
      end
    end

    context 'when viewing old version' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :reopened) }
      let(:old_authorization) do
        create(:authorization, request: authorization_request, applicant: authorization_request.applicant, created_at: 2.days.ago)
      end
      let(:authorization) { old_authorization }

      before { render_inline(component) }

      it 'renders the old version alert with warning style' do
        expect(page).to have_css('.fr-alert.fr-alert--warning')
        expect(page).to have_content(I18n.t('authorization_request_forms.summary.reopening_alerts.old_version.title'))
      end

      it 'renders link to latest authorization' do
        latest = authorization_request.latest_authorization
        expect(page).to have_link("Habilitation n°#{latest.id}")
      end

      it 'does not render update in progress alert' do
        expect(page).to have_no_content(I18n.t('authorization_request_forms.summary.reopening_alerts.update_in_progress.title'))
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
        expect(page).to have_no_css('.fr-alert')
        expect(page).to have_no_css('.fr-callout')
      end

      it 'does not render component' do
        expect(component.render?).to be false
      end
    end
  end
end
