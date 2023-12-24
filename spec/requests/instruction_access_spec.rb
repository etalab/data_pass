RSpec.describe 'Instruction access' do
  subject(:visit_instruction) do
    get instruction_path

    response
  end

  before do
    sign_in(user)
  end

  context 'when user is an instructor' do
    let(:user) { create(:user, :instructor) }

    it 'can access the instruction' do
      visit_instruction

      follow_redirect!

      expect(response).to have_http_status(:success)
    end
  end

  context 'when user is not an instructor' do
    let(:user) { create(:user) }

    it 'can not access the instruction space' do
      visit_instruction

      2.times { follow_redirect! }

      expect(response.body).to include('pas le droit')
    end
  end
end
