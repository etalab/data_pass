RSpec.describe 'Deletion modal of an authorization request draft' do
  let(:user) { create(:user) }
  let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, applicant: user) }

  before do
    sign_in(user)
    get new_authorization_request_archive_path(authorization_request)
  end

  it 'keeps « Annuler » first and « Supprimer la demande » with its icon, for a form without its own buttons' do
    buttons = Capybara.string(response.body).all('.fr-modal__footer .fr-btn')

    expect(buttons.map { |button| button.text.strip }).to eq(['Annuler', 'Supprimer la demande'])
    expect(buttons.last[:class]).to include('fr-icon-success-line')
  end
end
