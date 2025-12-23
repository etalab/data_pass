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
      @options = normalize_options(options)
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
        option = options.find { |opt| opt[:value].to_s == selected.first }
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

      enabled_options = options.reject { |opt| opt[:disabled] }
      enabled_options.all? { |opt| selected.include?(opt[:value].to_s) }
    end

    def none_selected?
      selected.empty?
    end

    private

    def normalize_options(opts)
      opts.map do |opt|
        case opt
        when Array
          { label: opt[0], value: opt[1], disabled: opt[2] || false }
        when Hash
          { label: opt[:label], value: opt[:value], disabled: opt[:disabled] || false }
        else
          { label: opt.to_s, value: opt.to_s, disabled: false }
        end
      end
    end
  end
end
