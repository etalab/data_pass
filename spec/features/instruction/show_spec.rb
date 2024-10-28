RSpec.describe 'Instruction: show an habilitation' do
  let(:user) { create(:user, :instructor, authorization_request_types:) }
  let(:authorization_request_types) do
    AuthorizationDefinition.all.map(&:id)
  end

  before do
    sign_in(user)
  end

  it 'works for each form' do
    AuthorizationRequestForm.all.each do |authorization_request_form|
      authorization_request = create(:authorization_request, authorization_request_form.uid.underscore)

      expect {
        visit instruction_authorization_request_path(authorization_request)
      }.not_to raise_error, "AuthorizationRequestForm: #{authorization_request_form.uid} does not work"
    end
  end
end
