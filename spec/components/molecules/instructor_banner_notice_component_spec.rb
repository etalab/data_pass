RSpec.describe Molecules::InstructorBannerNoticeComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new(authorization_request:)) }

  context 'when the request requires changes' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :changes_requested) }

    it 'names the request by its number' do
      expect(page_content).to have_text("Votre demande #{authorization_request.formatted_id} nécessite des modifications avant d’être validée")
    end
  end

  context 'when the request is refused' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :refused) }

    it 'names the request by its number' do
      expect(page_content).to have_text("Votre demande #{authorization_request.formatted_id} a été refusée")
    end
  end
end
