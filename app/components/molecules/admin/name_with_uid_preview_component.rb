class Molecules::Admin::NameWithUidPreviewComponent < ApplicationComponent
  def initialize(form:, record:, uid_label:)
    @form = form
    @record = record
    @uid_label = uid_label
  end

  private

  attr_reader :form, :record, :uid_label
end
