class Molecules::Instruction::WideHeader < ApplicationComponent
  renders_one :subtitle_content
  renders_one :right_content

  def initialize(title:, logo_asset: nil, dsfr_logo: nil, back_link: nil)
    @title = title
    @logo_asset = logo_asset
    @dsfr_logo = dsfr_logo
    @back_link = back_link
  end

  private

  attr_reader :title, :logo_asset, :dsfr_logo, :back_link
end
