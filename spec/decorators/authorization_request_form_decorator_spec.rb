RSpec.describe AuthorizationRequestFormDecorator do
  describe '#tags' do
    subject(:tags) { authorization_request_form.decorate.tags }

    context 'with use case and editor' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise-mgdis') }

      it { is_expected.to contain_exactly('aides_publiques', 'mgdis') }
    end

    context 'with default one' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise') }

      it { is_expected.to contain_exactly('default') }
    end
  end
end
