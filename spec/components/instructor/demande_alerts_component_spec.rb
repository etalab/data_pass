RSpec.describe Instructor::DemandeAlertsComponent, type: :component do
  let(:authorization_request) { create(:authorization_request, :api_entreprise, :reopened) }
  let(:component) { described_class.new(authorization_request:) }

  describe 'rendering' do
    context 'when reopening is in progress' do
      before { render_inline(component) }

      it 'renders the reopening callout' do
        expect(page).to have_css('.fr-callout.fr-icon-information-line')
      end

      it 'renders the reopening callout title' do
        expect(page).to have_content("Mise à jour de l'habilitation")
      end

      it 'renders the instructor text' do
        expect(page).to have_content(I18n.t('authorization_requests.shared.reopening_callout.text.instructor').strip)
      end

      it 'renders the link to authorization' do
        expect(page).to have_link(
          I18n.t(
            'authorization_requests.shared.reopening_callout.link.text',
            authorization_created_at: authorization_request.latest_authorization.created_at.to_date
          )
        )
      end
    end

    context 'when not reopening' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

      it 'renders nothing' do
        render_inline(component)
        expect(page.text).to be_empty
      end
    end
  end
end
