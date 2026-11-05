RSpec.describe EligibilityOptionDecorator, type: :decorator do
  let(:option_attributes) do
    {
      'type' => 'particulier',
      'eligible' => 'no',
      'body' => 'You are <strong>not</strong> eligible',
      'cta' => {
        'content' => 'Learn more',
        'url' => 'https://example.com/learn-more'
      }
    }
  end

  let(:option) { EligibilityOption.new(option_attributes) }
  let(:decorator) { option.decorate }

  describe '#id' do
    it 'returns the DOM id for the option' do
      expect(decorator.id).to eq('particulier-option')
    end
  end

  describe '#outcome_id' do
    it 'returns the DOM id for the outcome' do
      expect(decorator.outcome_id).to eq('particulier-outcome')
    end
  end

  describe '#alert_class' do
    context 'when eligible is yes' do
      let(:option_attributes) { { 'type' => 'collectivite_ou_administration', 'eligible' => 'yes', 'body' => 'Test' } }

      it 'returns green class' do
        expect(decorator.alert_class).to eq('fr-callout--green-emeraude')
      end
    end

    context 'when eligible is no' do
      let(:option_attributes) { { 'type' => 'particulier', 'eligible' => 'no', 'body' => 'Test' } }

      it 'returns pink class' do
        expect(decorator.alert_class).to eq('fr-callout--pink-macaron')
      end
    end

    context 'when eligible is maybe' do
      let(:option_attributes) { { 'type' => 'entreprise_ou_association', 'eligible' => 'maybe', 'body' => 'Test' } }

      it 'returns yellow class' do
        expect(decorator.alert_class).to eq('fr-callout--yellow-tournesol')
      end
    end
  end

  describe '#sanitized_body' do
    it 'sanitizes HTML in the body' do
      result = decorator.sanitized_body
      expect(result).to include('not')
      expect(result).to include('<strong>')
    end

    it 'strips dangerous tags' do
      option_attributes['body'] = 'Test <script>alert("XSS")</script>'
      result = decorator.sanitized_body
      expect(result).not_to include('<script>')
      expect(result).to include('Test')
    end
  end

  describe '#label' do
    it 'returns the translated label for the user type' do
      expect(decorator.label).to eq('Un particulier')
    end

    context 'with a custom label' do
      let(:option_attributes) { { 'type' => 'particulier', 'label' => 'Un éditeur', 'eligible' => 'no', 'body' => 'Test' } }

      it 'uses the custom label' do
        expect(decorator.label).to eq('Un éditeur')
      end
    end

    context 'when collectivite_ou_administration' do
      let(:option_attributes) { { 'type' => 'collectivite_ou_administration', 'eligible' => 'yes', 'body' => 'Test' } }

      it 'returns the correct translation' do
        expect(decorator.label).to eq('Une collectivité ou une administration')
      end
    end

    context 'when eaje' do
      let(:option_attributes) { { 'type' => 'eaje', 'eligible' => 'yes', 'body' => 'Test' } }

      it 'returns the correct translation' do
        expect(decorator.label).to eq('Un établissement d’accueil du jeune enfant (EAJE)')
      end
    end
  end

  describe '#shows_request_access_button?' do
    context 'when eligible is yes' do
      let(:option_attributes) { { 'type' => 'collectivite_ou_administration', 'eligible' => 'yes', 'body' => 'Test' } }

      it 'returns true' do
        expect(decorator.shows_request_access_button?).to be true
      end
    end

    context 'when eligible is maybe' do
      let(:option_attributes) { { 'type' => 'entreprise_ou_association', 'eligible' => 'maybe', 'body' => 'Test' } }

      it 'returns true' do
        expect(decorator.shows_request_access_button?).to be true
      end
    end

    context 'when eligible is no' do
      let(:option_attributes) { { 'type' => 'particulier', 'eligible' => 'no', 'body' => 'Test' } }

      it 'returns false' do
        expect(decorator.shows_request_access_button?).to be false
      end
    end
  end

  describe '#shows_custom_cta?' do
    context 'when cta is present with url' do
      let(:option_attributes) do
        {
          'type' => 'particulier',
          'eligible' => 'no',
          'body' => 'Test',
          'cta' => { 'content' => 'Learn more', 'url' => 'https://example.com' }
        }
      end

      it 'returns true' do
        expect(decorator.shows_custom_cta?).to be true
      end
    end

    context 'when cta is present but url is empty' do
      let(:option_attributes) do
        {
          'type' => 'particulier',
          'eligible' => 'no',
          'body' => 'Test',
          'cta' => { 'content' => 'Learn more', 'url' => '' }
        }
      end

      it 'returns false' do
        expect(decorator.shows_custom_cta?).to be false
      end
    end

    context 'when cta is nil' do
      let(:option_attributes) { { 'type' => 'particulier', 'eligible' => 'no', 'body' => 'Test', 'cta' => nil } }

      it 'returns false' do
        expect(decorator.shows_custom_cta?).to be false
      end
    end
  end

  describe '#cta_content' do
    it 'returns the cta content' do
      expect(decorator.cta_content).to eq('Learn more')
    end
  end

  describe '#cta_url' do
    it 'returns the cta url' do
      expect(decorator.cta_url).to eq('https://example.com/learn-more')
    end
  end

  describe '#cta_html_options' do
    it 'does not open a new tab by default' do
      expect(decorator.cta_html_options).not_to include(:target)
    end

    context 'when the cta opens in a new tab' do
      let(:option_attributes) do
        { 'type' => 'particulier', 'eligible' => 'no', 'body' => 'Test', 'cta' => { 'content' => 'Go', 'url' => 'https://example.com', 'new_tab' => true } }
      end

      it 'announces the new window and secures the link' do
        expect(decorator.cta_html_options).to include(target: '_blank', rel: 'noopener noreferrer', title: 'Go - nouvelle fenêtre')
      end
    end
  end
end
