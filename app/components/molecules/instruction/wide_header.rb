class Molecules::Instruction::WideHeader < ApplicationComponent
  renders_one :subtitle_content
  renders_one :right_content

  def initialize(title:, logo_asset: nil, dsfr_logo: nil, breadcrumbs: nil)
    @title = title
    @logo_asset = logo_asset
    @dsfr_logo = dsfr_logo
    @breadcrumbs = breadcrumbs
  end

  private

  attr_reader :title, :logo_asset, :dsfr_logo, :breadcrumbs
end
