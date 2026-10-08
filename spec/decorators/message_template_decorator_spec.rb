RSpec.describe MessageTemplateDecorator, type: :decorator do
  describe '#preview_mail' do
    subject(:preview_mail) { message_template.decorate.preview_mail(entity_name: 'Jean Dupont') }

    let(:message_template) { build(:message_template, content: 'Contenu <b>brut</b> du modèle') }

    context 'when the preview renders' do
      it 'renders the mailer template' do
        expect(preview_mail).to include('a été refusée')
      end
    end

    context 'when the preview rendering fails' do
      let(:rendering_error) { StandardError.new('gabarit cassé') }

      before do
        allow(MessageTemplatePreviewRenderer).to receive(:new).and_raise(rendering_error)
        allow(Sentry).to receive(:capture_exception)
      end

      it 'falls back to the escaped template content' do
        expect(preview_mail).to include('Contenu &lt;b&gt;brut&lt;/b&gt; du modèle')
      end

      it 'tracks the error' do
        preview_mail

        expect(Sentry).to have_received(:capture_exception).with(rendering_error)
      end
    end
  end
end
