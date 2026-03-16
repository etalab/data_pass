module MailSpecHelpers
  def decoded_text_body(mail)
    mail.multipart? ? mail.text_part.body.decoded : mail.body.decoded
  end

  def decoded_html_body(mail)
    mail.html_part&.body&.decoded
  end
end
