# frozen_string_literal: true

class Molecules::Admin::LinksFormSectionComponent < ApplicationComponent
  def initialize(form:)
    @form = form
  end

  private

  attr_reader :form
end
