# frozen_string_literal: true

module Dsfr
  class MultiSelectComponent < ApplicationComponent
    attr_reader :name, :options, :selected, :label, :hint, :placeholder, :all_label,
      :show_select_all, :show_search, :search_placeholder, :disabled,
      :html_options, :message, :message_severity

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      name:,
      options:,
      selected: [],
      label: nil,
      hint: nil,
      placeholder: nil,
      all_label: 'Tous',
      show_select_all: true,
      show_search: false,
      search_placeholder: nil,
      disabled: false,
      message: nil,
      message_severity: nil,
      **html_options
    )
      @name = name
      @options = options
      @selected = Array(selected).compact.map(&:to_s)
      @label = label
      @hint = hint
      @placeholder = placeholder || 'Sélectionner une option'
      @all_label = all_label
      @show_select_all = show_select_all
      @show_search = show_search
      @search_placeholder = search_placeholder || 'Rechercher'
      @disabled = disabled
      @message = message
      @message_severity = message_severity
      @html_options = html_options
    end
    # rubocop:enable Metrics/ParameterLists

    def component_id
      @component_id ||= html_options[:id] || "multi_select_#{SecureRandom.hex(4)}"
    end

    def listbox_id
      "#{component_id}-listbox"
    end

    def label_id
      "#{component_id}-label"
    end

    def searchbox_id
      "#{component_id}-searchbox"
    end

    def native_select_id
      "#{component_id}-native"
    end

    def messages_id
      "#{component_id}-messages"
    end

    def select_group_classes
      classes = %w[fr-select-group dsfrx-select]
      classes << "fr-select-group--#{message_severity}" if message
      classes << 'fr-select-group--disabled' if disabled
      classes.join(' ')
    end

    def control_classes
      classes = ['fr-select']
      classes << 'fr-select--disabled' if disabled
      classes.join(' ')
    end

    def display_label
      return placeholder if selected.empty?

      if selected.size == 1
        option = flat_options.find { |opt| opt[:value].to_s == selected.first }
        option ? option[:label] : placeholder
      else
        "#{selected.size} sélectionnés"
      end
    end

    def option_selected?(option)
      selected.include?(option[:value].to_s)
    end

    def all_selected?
      return true if selected.empty?

      enabled_options = flat_options.reject { |opt| opt[:disabled] }
      enabled_options.all? { |opt| selected.include?(opt[:value].to_s) }
    end

    def none_selected?
      selected.empty?
    end

    # Returns normalized options structure that supports groups
    # Groups have: { group: true, label: "Group Name", options: [...] }
    # Options have: { label: "Label", value: "value", disabled: false }
    def normalized_options
      @normalized_options ||= options.map { |opt| normalize_item(opt) }
    end

    # Flat list of all selectable options (excludes group headers)
    def flat_options
      @flat_options ||= normalized_options.flat_map do |item|
        item[:group] ? item[:options] : [item]
      end
    end

    # Render a single option item
    def render_option(option, index)
      render(OptionComponent.new(
        option:,
        index:,
        component_id:,
        selected: option_selected?(option)
      ))
    end

    private

    def normalize_item(opt)
      case opt
      when Array then normalize_array_item(opt)
      when Hash then normalize_hash_item(opt)
      else { label: opt.to_s, value: opt.to_s, disabled: false }
      end
    end

    def normalize_array_item(opt)
      if opt[1].is_a?(Array)
        { group: true, label: opt[0], options: opt[1].map { |o| normalize_single_option(o) } }
      else
        normalize_single_option(opt)
      end
    end

    def normalize_hash_item(opt)
      if opt[:options]
        { group: true, label: opt[:label], options: opt[:options].map { |o| normalize_single_option(o) } }
      else
        normalize_single_option(opt)
      end
    end

    def normalize_single_option(opt)
      case opt
      when Array
        { label: opt[0], value: opt[1], disabled: opt[2] || false }
      when Hash
        { label: opt[:label], value: opt[:value], disabled: opt[:disabled] || false }
      else
        { label: opt.to_s, value: opt.to_s, disabled: false }
      end
    end

    # Inner component for rendering individual options
    class OptionComponent < ApplicationComponent
      attr_reader :option, :index, :component_id, :selected

      def initialize(option:, index:, component_id:, selected:)
        @option = option
        @index = index
        @component_id = component_id
        @selected = selected
      end

      def call
        content_tag(:li, option_attributes) do
          content_tag(:span, class: 'fr-checkbox-group fr-checkbox-group--sm') do
            checkbox_input + checkbox_label
          end
        end
      end

      private

      def option_attributes
        {
          role: 'option',
          class: option_classes,
          id: "#{component_id}-option-#{index}",
          tabindex: -1,
          'aria-checked': selected,
          'aria-disabled': option[:disabled] || nil,
          'data-value': option[:value],
          'data-label': option[:label],
          'data-index': index,
          'data-disabled': option[:disabled],
          'data-action': 'click->dsfr-multi-select#selectOption keydown->dsfr-multi-select#handleOptionKeydown'
        }
      end

      def option_classes
        classes = ['dsfrx-multiselect__item']
        classes << 'selected' if selected
        classes.join(' ')
      end

      def checkbox_input
        tag.input(
          type: 'checkbox',
          id: "#{component_id}-checkbox-#{index}",
          tabindex: -1,
          checked: selected || nil,
          disabled: option[:disabled] || nil,
          'data-dsfr-multi-select-target': 'checkbox'
        )
      end

      def checkbox_label
        label_classes = ['fr-label']
        label_classes << 'fr-label--disabled' if option[:disabled]

        content_tag(:label, class: label_classes.join(' '), for: "#{component_id}-checkbox-#{index}") do
          content_tag(:span, option[:label], class: 'text-node')
        end
      end
    end
  end
end
