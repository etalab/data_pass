module Dsfr::MultiSelect
  def dsfr_multi_select(name, options, selected: [], all_label: 'Tous', html_options: {})
    id = html_options[:id] || "multi_select_#{SecureRandom.hex(4)}"
    selected = Array(selected).compact.reject(&:blank?)

    template.content_tag(:div,
      class: ['multi-select', html_options[:class]].compact.flatten,
      data: {
        controller: 'multi-select',
        'multi-select-name-value': name,
        'multi-select-all-label-value': all_label
      },
      id: id) do
      [
        multi_select_trigger(selected, options, all_label),
        multi_select_dropdown(options, selected, all_label),
        multi_select_hidden_inputs(name, selected)
      ].join.html_safe
    end
  end

  private

  def multi_select_trigger(selected, options, all_label)
    label_text = multi_select_label_text(selected, options, all_label)

    template.button_tag(
      type: 'button',
      class: 'multi-select__trigger',
      data: {
        'multi-select-target': 'trigger',
        action: 'click->multi-select#toggle'
      },
      'aria-expanded': 'false',
      'aria-haspopup': 'listbox'
    ) do
      template.content_tag(:span, label_text,
        class: ['multi-select__label', selected.any? ? 'has-selection' : nil].compact,
        data: { 'multi-select-target': 'label' })
    end
  end

  def multi_select_dropdown(options, selected, all_label)
    template.content_tag(:div,
      class: ['multi-select__dropdown', 'fr-hidden'],
      data: { 'multi-select-target': 'dropdown' },
      'aria-hidden': 'true',
      role: 'listbox',
      'aria-multiselectable': 'true') do
      [
        multi_select_clear_button(all_label),
        multi_select_options_list(options, selected)
      ].join.html_safe
    end
  end

  def multi_select_options_list(options, selected)
    template.content_tag(:ul,
      class: 'multi-select__options',
      data: { 'multi-select-target': 'optionsList' }) do
      options.map do |label, value|
        is_selected = selected.include?(value.to_s)
        multi_select_option(label, value, is_selected)
      end.join.html_safe
    end
  end

  def multi_select_option(label, value, is_selected)
    template.content_tag(:li,
      class: ['multi-select__option', is_selected ? 'selected' : nil].compact,
      data: {
        action: 'click->multi-select#selectOption',
        'multi-select-value-param': value,
        'multi-select-label-param': label,
        preselected: is_selected ? 'true' : nil
      }.compact,
      role: 'option',
      'aria-selected': is_selected.to_s) do
      template.content_tag(:span, label, class: 'multi-select__option-text')
    end
  end

  def multi_select_clear_button(all_label)
    template.button_tag(
      "#{all_label}",
      type: 'button',
      class: 'multi-select__clear',
      data: { action: 'click->multi-select#clearAll' }
    )
  end

  def multi_select_hidden_inputs(name, selected)
    template.content_tag(:div,
      class: 'multi-select__hidden-inputs',
      data: { 'multi-select-target': 'hiddenInputs' }) do
      selected.map do |value|
        template.hidden_field_tag(name, value)
      end.join.html_safe
    end
  end

  def multi_select_label_text(selected, options, all_label)
    return all_label if selected.empty?

    if selected.size == 1
      option = options.find { |_, v| v.to_s == selected.first.to_s }
      option ? option.first : all_label
    else
      "#{selected.size} sélectionnés"
    end
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def template
    @template || self
  end
  # rubocop:enable Rails/HelperInstanceVariable
end

