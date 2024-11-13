class ErrorsController < PublicController
  include Gaffe::Errors

  layout 'application'

  helper_method :user_signed_in?

  def show
    render 'show',
      status: @status_code
  end
end
