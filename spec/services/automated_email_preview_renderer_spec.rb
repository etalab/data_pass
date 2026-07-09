RSpec.describe AutomatedEmailPreviewRenderer do
  subject(:renderer) { described_class.new(definition, email) }

  let(:definition) { AuthorizationDefinition.find('annuaire_des_entreprises') }

  def build_email(mailer, action, state)
    AuthorizationDefinition::AutomatedEmails::Email.new(mailer:, action:, state:)
  end

  describe '#call' do
    subject(:rendered) { renderer.call }

    context 'when the mailer renders successfully' do
      let(:email) { build_email('AuthorizationRequestMailer', 'approve', { reopening: false }) }

      it 'returns the rendered subject, recipients and body' do
        expect(rendered.subject).to include('[numéro de la demande]')
        expect(rendered.recipients).to eq('[email du demandeur]')
        expect(rendered.body).to be_present
        expect(rendered.error).to be_nil
      end
    end

    context 'when the mailer is unknown' do
      let(:email) { build_email('UnknownMailer', 'approve', { reopening: false }) }

      it 'returns a blank preview with the error message' do
        expect(rendered.subject).to be_nil
        expect(rendered.recipients).to be_nil
        expect(rendered.body).to be_nil
        expect(rendered.error).to include('NoMethodError')
      end

      it 'reports the error to Sentry' do
        allow(Sentry).to receive(:capture_exception)

        renderer.call

        expect(Sentry).to have_received(:capture_exception).with(instance_of(NoMethodError))
      end
    end
  end
end
