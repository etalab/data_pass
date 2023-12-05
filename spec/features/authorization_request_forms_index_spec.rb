RSpec.describe 'Authorization requests forms index' do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  it 'displays form entries' do
    visit authorization_request_forms_path

    AuthorizationRequestForm.where(public: true).each do |form|
      expect(page).to have_css(css_id(form))
      expect(page).to have_content form.name
    end
  end
end
