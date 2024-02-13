# app/mailers/sendgrid_mailer.rb
class SendGridMailer < ApplicationMailer
  require 'sendgrid-ruby'
  include SendGrid

  def send_email
    from = Email.new(email: 'rchelton@riverdaleparkmd.gov')
    to = Email.new(email: 'ryanmchelton@gmail.com') # Change to actual recipient email
    subject = 'Sending with SendGrid is Fun'
    content = Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
    mail = Mail.new(from, subject, to, content)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end
