Rails.application.reloader.to_prepare do
  ActionMailer::Base.register_interceptor(LinkifyUrlsInterceptor)
end
