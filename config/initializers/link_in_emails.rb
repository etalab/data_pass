Rails.application.reloader.to_prepare do
  ActionMailer::Base.register_interceptor(LinkInEmailsInterceptor)
  ActionMailer::Base.register_preview_interceptor(LinkInEmailsInterceptor)
end
