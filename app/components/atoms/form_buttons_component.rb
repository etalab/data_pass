class Atoms::FormButtonsComponent < ApplicationComponent
  def initialize(copy_request_url:, initiate_request_path: nil)
    @initiate_request_path = initiate_request_path
    @copy_request_url = copy_request_url
  end

  private

  attr_reader :initiate_request_path, :copy_request_url
end
