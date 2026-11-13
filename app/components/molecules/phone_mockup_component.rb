class Molecules::PhoneMockupComponent < ApplicationComponent
  def initialize(caption:, header:, rows:, status: nil, actions: [])
    @caption_id = caption.fetch(:id)
    @caption_text = caption.fetch(:text)
    @avatar = header.fetch(:avatar)
    @title = header.fetch(:title)
    @subtitle = header.fetch(:subtitle)
    @rows = rows
    @status = status
    @actions = actions
  end

  attr_reader :caption_id, :caption_text, :avatar, :title, :subtitle, :rows, :status, :actions
end
