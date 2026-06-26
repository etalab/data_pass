class Atoms::CopyButtonComponent < ApplicationComponent
  def initialize(text_to_copy:, label:, extra_classes: nil)
    @text_to_copy = text_to_copy
    @label = label
    @extra_classes = extra_classes
  end

  private

  attr_reader :text_to_copy, :label, :extra_classes

  def button_classes
    classes = %w[fr-btn fr-btn--secondary fr-btn--icon-left fr-icon-clipboard-line]
    classes << extra_classes if extra_classes
    classes.join(' ')
  end
end
