# frozen_string_literal: true

RSpec.describe Dsfr::MultiSelectComponent, type: :component do
  let(:name) { 'test[options][]' }
  let(:options) { [%w[Option1 value1], %w[Option2 value2], %w[Option3 value3]] }
  let(:label) { 'Test Label' }

  describe 'native select (no JavaScript fallback)' do
    it 'renders a native multiple select element' do
      render_inline(described_class.new(
        name: name,
        options: options,
        label: label
      ))

      expect(page).to have_css('select[multiple].dsfrx-multiselect__native')
      expect(page).to have_select('test[options][]')
    end

    it 'renders all options in the native select' do
      render_inline(described_class.new(
        name: name,
        options: options,
        label: label
      ))

      within('select.dsfrx-multiselect__native') do
        expect(page).to have_css('option', count: 3)
        expect(page).to have_css('option[value="value1"]', text: 'Option1')
        expect(page).to have_css('option[value="value2"]', text: 'Option2')
        expect(page).to have_css('option[value="value3"]', text: 'Option3')
      end
    end

    it 'marks selected options as selected in native select' do
      render_inline(described_class.new(
        name: name,
        options: options,
        selected: %w[value1 value3],
        label: label
      ))

      within('select.dsfrx-multiselect__native') do
        expect(page).to have_css('option[value="value1"][selected]')
        expect(page).to have_css('option[value="value2"]:not([selected])')
        expect(page).to have_css('option[value="value3"][selected]')
      end
    end

    context 'with grouped options' do
      let(:grouped_options) do
        [
          { label: 'Group 1', options: [%w[Option1 value1], %w[Option2 value2]] },
          { label: 'Group 2', options: [%w[Option3 value3], %w[Option4 value4]] }
        ]
      end

      it 'renders option groups in native select' do
        render_inline(described_class.new(
          name: name,
          options: grouped_options,
          label: label
        ))

        within('select.dsfrx-multiselect__native') do
          expect(page).to have_css('optgroup[label="Group 1"]')
          expect(page).to have_css('optgroup[label="Group 2"]')

          within('optgroup[label="Group 1"]') do
            expect(page).to have_css('option[value="value1"]', text: 'Option1')
            expect(page).to have_css('option[value="value2"]', text: 'Option2')
          end

          within('optgroup[label="Group 2"]') do
            expect(page).to have_css('option[value="value3"]', text: 'Option3')
            expect(page).to have_css('option[value="value4"]', text: 'Option4')
          end
        end
      end
    end

    context 'with disabled options' do
      let(:options_with_disabled) do
        [
          ['Option1', 'value1', false],
          ['Option2', 'value2', true],
          ['Option3', 'value3', false]
        ]
      end

      it 'marks disabled options as disabled in native select' do
        render_inline(described_class.new(
          name: name,
          options: options_with_disabled,
          label: label
        ))

        within('select.dsfrx-multiselect__native') do
          expect(page).to have_css('option[value="value1"]:not([disabled])')
          expect(page).to have_css('option[value="value2"][disabled]')
          expect(page).to have_css('option[value="value3"]:not([disabled])')
        end
      end
    end

    it 'renders the label associated with native select' do
      render_inline(described_class.new(
        name: name,
        options: options,
        label: label
      ))

      expect(page).to have_css('label.fr-label', text: 'Test Label')
      label_element = page.find('label.fr-label', text: 'Test Label')
      select_element = page.find('select.dsfrx-multiselect__native')
      expect(label_element[:for]).to eq(select_element[:id])
    end
  end

  describe 'enhanced JavaScript component' do
    it 'renders the enhanced multi-select container' do
      render_inline(described_class.new(
        name: name,
        options: options,
        label: label
      ))

      expect(page).to have_css('.dsfrx-multiselect.dsfrx-multiselect--js-only')
      expect(page).to have_css('[data-controller="dsfr-multi-select"]')
    end

    it 'renders the combobox trigger' do
      render_inline(described_class.new(
        name: name,
        options: options,
        label: label
      ))

      expect(page).to have_css('.fr-select[role="combobox"]')
      expect(page).to have_css('[data-dsfr-multi-select-target="trigger"]')
    end

    context 'when displaying label' do
      it 'shows placeholder when nothing is selected' do
        render_inline(described_class.new(
          name: name,
          options: options,
          placeholder: 'Choose options',
          label: label
        ))

        within('.dsfrx-multiselect__label') do
          expect(page).to have_text('Choose options')
        end
        expect(page).to have_css('.dsfrx-multiselect__label.dsfrx-multiselect--placeholder')
      end

      it 'shows single option label when one is selected' do
        render_inline(described_class.new(
          name: name,
          options: options,
          selected: ['value2'],
          label: label
        ))

        within('.dsfrx-multiselect__label') do
          expect(page).to have_text('Option2')
        end
        expect(page).to have_no_css('.dsfrx-multiselect__label.dsfrx-multiselect--placeholder')
      end

      it 'shows count when multiple options are selected' do
        render_inline(described_class.new(
          name: name,
          options: options,
          selected: %w[value1 value3],
          label: label
        ))

        within('.dsfrx-multiselect__label') do
          expect(page).to have_text('2 sélectionnés')
        end
      end
    end

    it 'renders all options in the listbox' do
      render_inline(described_class.new(
        name: name,
        options: options,
        label: label
      ))

      within('[role="listbox"]') do
        expect(page).to have_css('[role="option"]', count: 3)
        expect(page).to have_css('[role="option"][data-value="value1"]')
        expect(page).to have_css('[role="option"][data-value="value2"]')
        expect(page).to have_css('[role="option"][data-value="value3"]')
      end
    end

    it 'marks selected options with aria-checked and selected class' do
      render_inline(described_class.new(
        name: name,
        options: options,
        selected: %w[value1 value3],
        label: label
      ))

      within('[role="listbox"]') do
        expect(page).to have_css('[role="option"][data-value="value1"][aria-checked="true"].selected')
        expect(page).to have_css('[role="option"][data-value="value2"][aria-checked="false"]:not(.selected)')
        expect(page).to have_css('[role="option"][data-value="value3"][aria-checked="true"].selected')
      end
    end

    context 'with grouped options' do
      let(:grouped_options) do
        [
          { label: 'API Group', options: [%w[API1 api1], %w[API2 api2]] },
          { label: 'Service Group', options: [%w[Service1 svc1], %w[Service2 svc2]] }
        ]
      end

      it 'renders groups with proper structure' do
        render_inline(described_class.new(
          name: name,
          options: grouped_options,
          label: label
        ))

        expect(page).to have_css('[role="group"]', count: 2)
        expect(page).to have_css('.dsfrx-multiselect__group-label', text: 'API Group')
        expect(page).to have_css('.dsfrx-multiselect__group-label', text: 'Service Group')
      end

      it 'renders options within groups' do
        render_inline(described_class.new(
          name: name,
          options: grouped_options,
          label: label
        ))

        groups = page.all('[role="group"]')

        within(groups[0]) do
          expect(page).to have_css('[role="option"][data-value="api1"]')
          expect(page).to have_css('[role="option"][data-value="api2"]')
        end

        within(groups[1]) do
          expect(page).to have_css('[role="option"][data-value="svc1"]')
          expect(page).to have_css('[role="option"][data-value="svc2"]')
        end
      end
    end

    context 'with select all button' do
      it 'shows "Tout sélectionner" when nothing is selected' do
        render_inline(described_class.new(
          name: name,
          options: options,
          label: label
        ))

        within('.dsfrx-multiselect__toolbar') do
          expect(page).to have_button(class: 'fr-btn--select-all')
          expect(page).to have_text('Tout sélectionner')
        end
      end

      it 'shows "Tout désélectionner" when options are selected' do
        render_inline(described_class.new(
          name: name,
          options: options,
          selected: ['value1'],
          label: label
        ))

        within('.dsfrx-multiselect__toolbar') do
          expect(page).to have_text('Tout désélectionner')
        end
      end
    end

    context 'with disabled options' do
      let(:options_with_disabled) do
        [
          { label: 'Option1', value: 'value1', disabled: false },
          { label: 'Option2', value: 'value2', disabled: true },
          { label: 'Option3', value: 'value3', disabled: false }
        ]
      end

      it 'marks disabled options with aria-disabled' do
        render_inline(described_class.new(
          name: name,
          options: options_with_disabled,
          label: label
        ))

        within('[role="listbox"]') do
          expect(page).to have_css('[role="option"][data-value="value1"]:not([aria-disabled])')
          expect(page).to have_css('[role="option"][data-value="value2"][aria-disabled="true"]')
          expect(page).to have_css('[role="option"][data-value="value3"]:not([aria-disabled])')
        end
      end

      it 'marks disabled option checkboxes as disabled' do
        render_inline(described_class.new(
          name: name,
          options: options_with_disabled,
          label: label
        ))

        disabled_option = page.find('[role="option"][data-value="value2"]')
        checkbox = disabled_option.find('input[type="checkbox"]')
        expect(checkbox[:disabled]).to be_present
      end
    end

    it 'creates hidden inputs for selected values' do
      render_inline(described_class.new(
        name: name,
        options: options,
        selected: %w[value1 value3],
        label: label
      ))

      within('.dsfrx-multiselect__hidden-inputs') do
        inputs = page.all('input[type="hidden"][name="test[options][]"]')
        expect(inputs.count).to eq(2)
        expect(inputs[0][:value]).to eq('value1')
        expect(inputs[1][:value]).to eq('value3')
      end
    end

    it 'sets data attributes for Stimulus controller' do
      render_inline(described_class.new(
        name: name,
        options: options,
        placeholder: 'Custom placeholder',
        label: label
      ))

      container = page.find('[data-controller="dsfr-multi-select"]')
      expect(container['data-dsfr-multi-select-name-value']).to eq(name)
      expect(container['data-dsfr-multi-select-placeholder-value']).to eq('Custom placeholder')
    end
  end

  describe 'accessibility' do
    it 'has proper ARIA attributes for combobox' do
      render_inline(described_class.new(
        name: name,
        options: options,
        label: label
      ))

      trigger = page.find('[role="combobox"]')
      expect(trigger['aria-haspopup']).to eq('listbox')
      expect(trigger['aria-expanded']).to eq('false')
      expect(trigger['aria-controls']).to be_present

      listbox = page.find('[role="listbox"]')
      expect(trigger['aria-controls']).to eq(listbox[:id])
    end

    it 'links label to native select' do
      render_inline(described_class.new(
        name: name,
        options: options,
        label: label
      ))

      label_element = page.find('label.fr-label', text: 'Test Label')
      select_element = page.find('select.dsfrx-multiselect__native')
      expect(label_element[:for]).to eq(select_element[:id])
    end

    it 'has proper ARIA attributes for options' do
      render_inline(described_class.new(
        name: name,
        options: options,
        selected: ['value2'],
        label: label
      ))

      within('[role="listbox"]') do
        options = page.all('[role="option"]')
        expect(options[0]['aria-checked']).to eq('false')
        expect(options[1]['aria-checked']).to eq('true')
        expect(options[2]['aria-checked']).to eq('false')
      end
    end
  end

  describe 'option normalization' do
    it 'handles string options' do
      render_inline(described_class.new(
        name: name,
        options: %w[opt1 opt2 opt3],
        label: label
      ))

      within('select.dsfrx-multiselect__native') do
        expect(page).to have_css('option[value="opt1"]', text: 'opt1')
        expect(page).to have_css('option[value="opt2"]', text: 'opt2')
        expect(page).to have_css('option[value="opt3"]', text: 'opt3')
      end
    end

    it 'handles array options [label, value]' do
      render_inline(described_class.new(
        name: name,
        options: [%w[Label1 val1], %w[Label2 val2]],
        label: label
      ))

      within('select.dsfrx-multiselect__native') do
        expect(page).to have_css('option[value="val1"]', text: 'Label1')
        expect(page).to have_css('option[value="val2"]', text: 'Label2')
      end
    end

    it 'handles hash options' do
      render_inline(described_class.new(
        name: name,
        options: [
          { label: 'Hash Label 1', value: 'hash_val1' },
          { label: 'Hash Label 2', value: 'hash_val2' }
        ],
        label: label
      ))

      within('select.dsfrx-multiselect__native') do
        expect(page).to have_css('option[value="hash_val1"]', text: 'Hash Label 1')
        expect(page).to have_css('option[value="hash_val2"]', text: 'Hash Label 2')
      end
    end
  end
end
