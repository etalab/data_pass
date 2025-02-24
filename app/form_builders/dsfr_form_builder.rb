class DSFRFormBuilder < ActionView::Helpers::FormBuilder
  include Rails.application.routes.url_helpers

  def dsfr_text_field(attribute, opts = {})
    dsfr_input_field(attribute, :text_field, opts)
  end

  def dsfr_email_field(attribute, opts = {})
    dsfr_input_field(attribute, :email_field, opts)
  end

  def dsfr_date_field(attribute, opts = {})
    dsfr_input_field(attribute, :date_field, opts)
  end

  def dsfr_text_area(attribute, opts = {})
    dsfr_input_field(attribute, :text_area, opts)
  end

  def dsfr_number_field(attribute, opts = {})
    dsfr_input_field(attribute, :number_field, opts)
  end

  def dsfr_url_field(attribute, opts = {})
    dsfr_input_field(attribute, :url_field, opts)
  end

  def dsfr_file_field(attribute, opts = {})
    opts[:class] ||= 'fr-upload-group'

    existing_file_link = link_to_files(attribute)
    required = opts[:required] && !existing_file_link

    dsfr_input_group(attribute, opts) do
      @template.safe_join(
        [
          label_with_hint(attribute, opts),
          file_field(attribute, class: 'fr-upload', autocomplete: 'off', required:, **enhance_input_options(opts).except(:class, :required)),
          error_message(attribute),
          existing_file_link,
        ].compact
      )
    end
  end

  def dsfr_check_box(attribute, opts = {})
    dsfr_input_group(attribute, opts) do
      @template.content_tag(:div, class: 'fr-checkbox-group') do
        @template.safe_join(
          [
            check_box(attribute, class: input_classes(opts), disabled: check_box_disabled, **enhance_input_options(opts).except(:class, :label)),
            @template.safe_join([opts[:label] || label_with_hint(attribute, opts)])
          ]
        )
      end
    end
  end

  def dsfr_input_group(attribute, opts, &block)
    @template.content_tag(:div, class: input_group_classes(attribute, opts)) do
      yield(block)
    end
  end

  def dsfr_radio_buttons(attribute, choices, opts = {})
    label_content = @template.content_tag(
      :legend,
      label_with_hint(attribute, opts.except(:input_options)),
      class: 'fr-fieldset__legend--regular fr-fieldset__legend'
    )

    @template.content_tag(:fieldset, class: 'fr-fieldset') do
      @template.safe_join(
        [
          label_content,
          choices.map { |choice| dsfr_radio_option(attribute, choice, opts.dup) }
        ].compact
      )
    end
  end

  def dsfr_radio_option(attribute, value, opts = { input_options: {} }, &)
    opts[:checked] = opts[:checked].call(value) if opts[:checked].is_a? Proc

    @template.content_tag(:div, class: "fr-fieldset__element #{opts[:fieldset_element_class]}") do
      @template.content_tag(:div, class: "fr-radio-group #{opts[:radio_group_class]}") do
        @template.safe_join(
          [
            radio_button(attribute, value, **opts.except(:checked_proc), **(opts[:input_options] || {})),
            dsfr_radio_label(attribute, value, &)
          ]
        )
      end
    end
  end

  def dsfr_radio_label(attribute, value, &label_block)
    full_attribute = [attribute, value].join('_').to_sym

    if block_given?
      label(full_attribute) { yield(label_block) }
    else
      label(full_attribute, label_value("#{attribute}.values.#{value}"))
    end
  end

  def dsfr_select(attribute, choices, opts = { input_options: {} })
    @template.content_tag(:div, class: 'fr-select-group') do
      @template.safe_join(
        [
          label_with_hint(attribute, opts.except(:input_options)),
          dsfr_select_tag(attribute, choices, **opts, **(opts[:input_options] || {})),
          error_message(attribute)
        ]
      )
    end
  end

  def dsfr_malware_badge(attribute, opts = {})
    safety_state = attribute.malware_scan&.safety_state || 'absent'

    badge_class = I18n.t("malware_scan.badge_class.#{safety_state}")
    label = I18n.t("malware_scan.label.#{safety_state}")

    @template.content_tag(:p, class: "fr-badge fr-badge--#{badge_class} malware-badge #{opts[:class]}") do
      label_value(label)
    end
  end

  def dsfr_check_boxes(attribute, choices, opts = {})
    @template.content_tag(:fieldset, class: 'fr-fieldset') do
      if opts[:label]
        @template.safe_join(
          [dsfr_check_boxes_legend(attribute, opts)] +
          choices.map { |choice| dsfr_check_box_option(attribute, choice, opts.dup) }
        )
      else
        @template.safe_join(
          choices.map { |choice| dsfr_check_box_option(attribute, choice, opts.dup) }
        )
      end
    end
  end

  private

  def dsfr_check_boxes_legend(attribute, opts)
    @template.content_tag(
      :legend,
      label_with_hint(attribute, opts.except(:input_options)),
      class: 'fr-fieldset__legend--regular fr-fieldset__legend'
    )
  end

  def dsfr_check_box_option(attribute, value, opts = {})
    is_checked = opts[:checked].respond_to?(:call) ? opts[:checked].call(value) : false

    checkbox = check_box(attribute, { multiple: true, checked: is_checked }, value, nil)
    label_content = dsfr_radio_label(attribute, value)

    @template.content_tag(:div, class: "fr-fieldset__element #{opts[:fieldset_element_class]}") do
      @template.content_tag(:div, class: "fr-checkbox-group #{opts[:radio_group_class]}") do
        @template.safe_join([checkbox, label_content])
      end
    end
  end

  def dsfr_select_tag(attribute, choices, opts)
    select(attribute, choices, { include_blank: opts[:include_blank] }, class: 'fr-select', **enhance_input_options(opts).except(:class))
  end

  def dsfr_input_field(attribute, input_kind, opts = {})
    dsfr_input_group(attribute, opts) do
      @template.safe_join(
        [
          label_with_hint(attribute, opts),
          public_send(input_kind, attribute, class: input_classes(opts), autocomplete: 'off', **enhance_input_options(opts).except(:class)),
          error_message(attribute)
        ]
      )
    end
  end

  def label_with_hint(attribute, opts = {})
    label(attribute, class: 'fr-label') do
      label_text_container = @template.content_tag(:span) do
        label_value = [label_value(attribute)]
        label_value.push(required_tag) if opts[:required]
        @template.safe_join(label_value)
      end

      @template.safe_join(
        [
          label_text_container,
          hint(attribute)
        ]
      )
    end
  end

  def required_tag
    @template.content_tag(:span, '*', class: 'fr-ml-1w fr-text-error')
  end

  def hint(attribute)
    text = hint_for(attribute)

    return '' if text.blank?

    @template.content_tag(:span, class: 'fr-hint-text') do
      text
    end

    @template.content_tag(:span, text.html_safe, class: 'fr-hint-text')
  end

  def error_message(attr)
    return if @object.errors[attr].none?

    @template.content_tag(:p, class: 'fr-messages-group') do
      @object.errors.full_messages_for(attr).map { |msg|
        @template.content_tag(:span, msg, class: 'fr-message fr-message--error')
      }.join.html_safe
    end
  end

  def join_classes(arr)
    arr.compact.join(' ')
  end

  def input_classes(opts)
    join_classes(
      [
        'fr-input',
        opts[:code] && 'fr-input--code',
        input_width_class(opts)
      ]
    )
  end

  def link_to_files(attribute)
    files = @object.send(attribute)
    return unless files.attached?

    @template.content_tag(:div, class: 'fr-input-group__text fr-mt-1w') do
      Array(files).filter_map { |file|
        next unless file.persisted?

        create_file_link(file)
      }.join('<br>').html_safe
    end
  end

  def create_file_link(file)
    @template.link_to(
      file.filename,
      rails_blob_path(file, disposition: 'inline', only_path: true),
      target: '_blank',
      rel: 'noopener',
      class: 'fr-mb-1v'
    )
  end

  def input_width_class(opts)
    return '' if opts[:width].blank?

    opts[:width].split.map { |spec| "fr-col-#{spec}" }.join(' ')
  end

  def input_group_classes(attribute, opts)
    join_classes(
      [
        'fr-input-group',
        @object.errors[attribute].any? ? 'fr-input-group--error' : nil,
        opts[:class]
      ]
    )
  end

  def hint_for(attribute)
    I18n.t("activerecord.hints.#{@object.model_name.element}.#{attribute}", default: nil)
  end

  def label_value(attribute)
    (@object.try(:object) || @object).class.human_attribute_name(attribute)
  end

  def enhance_input_options(opts)
    opts
  end

  def check_box_disabled
    false
  end
end
