RSpec.describe IconComponent, type: :component do
  let(:component_class) do
    Class.new(IconComponent) do
      def self.name
        'TestIconComponent'
      end

      private

      def available_icons
        {
          'approve' => { icon: 'checkbox-line', color: 'success' },
          'request_changes' => { icon: 'pencil-line', color: 'warning' },
          'refuse' => { icon: 'close-circle-line', color: 'error' },
          'revoke' => { icon: 'close-circle-line', color: 'error' }
        }
      end
    end
  end

  let(:component) { component_class.new(name: icon_name) }

  context 'when icon is valid' do
    let(:icon_name) { 'approve' }

    it 'renders the correct icon and color class' do
      render_inline(component)

      expect(page).to have_css('i.fr-icon-checkbox-line.fr-text-success[aria-hidden="true"]')
    end
  end

  context 'when icon is invalid' do
    let(:icon_name) { 'checkbox' }

    it 'raises an error' do
      expect { render_inline(component) }.to raise_error('Invalid icon')
    end
  end
end
