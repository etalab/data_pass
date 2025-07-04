# rubocop:disable Metrics/ClassLength
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

  # rubocop:disable Metrics/AbcSize
  def dsfr_file_field(attribute, opts = {})
    opts[:class] ||= 'fr-upload-group'

    if opts[:multiple]
      opts[:input_group_options] ||= {}
      opts[:input_group_options][:data] ||= { controller: 'remove-attached-file' }
      opts[:input_group_options][:data][:removeAttachedFileTarget] = 'file'
      hidden_fields = hidden_fields_for_existing_attachments(attribute)
      existing_file_link = link_to_files(attribute)
    end

    required = required?(attribute, opts) && !existing_file_link

    dsfr_input_group(attribute, opts) do
      @template.safe_join(
        [
          label_with_hint(attribute, opts),
          file_field(attribute, class: 'fr-upload', autocomplete: 'off', required:, **enhance_input_options(opts).except(:class, :required)),
          error_message(attribute),
          existing_file_link,
          hidden_fields,
        ].compact
      )
    end
  end
  # rubocop:enable Metrics/AbcSize

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
    html_options = { class: input_group_classes(attribute, opts) }.merge(opts[:input_group_options] || {})

    @template.content_tag(:div, html_options) do
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

  def dsfr_radio_option(attribute, value, opts = { input_options: {} }, &) # rubocop:disable Metrics/AbcSize
    return if opts[:skipped].is_a?(Proc) && opts[:skipped].call(value)

    opts[:required] = required?(attribute, opts)
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
    options[:required] = required?(attribute, opts)

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

  private

  def dsfr_select_tag(attribute, choices, opts)
    select(attribute, choices, { include_blank: opts[:include_blank] }, class: 'fr-select', **enhance_input_options(opts).except(:class))
  end

  def dsfr_input_field(attribute, input_kind, opts = {})
    opts[:required] = required?(attribute, opts)

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

        link_to_blob_file_with_remove_button(attribute, file)
      }.join('<br>').html_safe
    end
  end

  def link_to_blob_file_with_remove_button(attribute, file)
    field_id = "#{@object_name}_#{attribute}_#{file.id}_signed_id"

    @template.content_tag(:div, class: 'file-with-remove-button') do
      [
        link_to_blob_file_within_files(file),
        @template.content_tag(:button,
          I18n.t('authorization_request_forms.form.delete_file'),
          type: 'button',
          class: 'fr-icon-delete-line fr-btn fr-btn--sm fr-btn--tertiary-no-outline fr-ml-1w',
          title: I18n.t('authorization_request_forms.form.delete_file'),
          data: {
            field_id: field_id,
            action: 'click->remove-attached-file#removeFile'
          })
      ].join.html_safe
    end
  end

  def link_to_blob_file_within_files(file)
    @template.link_to(
      file.filename,
      rails_blob_path(file, disposition: 'inline', only_path: true),
      target: '_blank',
      rel: 'noopener',
      class: 'fr-mb-1v'
    )
  end

  def hidden_fields_for_existing_attachments(attribute)
    files = @object.send(attribute)
    return unless files.attached?

    @template.safe_join(
      Array(files).filter_map do |file|
        next unless file.persisted?

        create_hidden_field_for_file(attribute, file)
      end
    )
  end

  def create_hidden_field_for_file(attribute, file)
    field_name = "#{@object_name}[#{attribute}][]"
    field_id = "#{@object_name}_#{attribute}_#{file.id}_signed_id"

    @template.hidden_field_tag(field_name, file.signed_id, id: field_id)
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

  def required?(attribute, options = {})
    if options.key?(:required)
      options[:required]
    else
      (@object.try(:object) || @object).class.validators_on(attribute).any? do |v|
        %i[presence acceptance].include?(v.kind)
      end
    end
  end

  def enhance_input_options(opts)
    opts
  end

  def check_box_disabled
    false
  end

  def multiple_attachments?(attribute)
    @object.class.attachment_reflections[attribute.to_s]&.macro == :has_many_attached
  end
end
# rubocop:enable Metrics/ClassLength
