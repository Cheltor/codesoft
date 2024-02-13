class NotificationMailer < ApplicationMailer
  require 'sendgrid-ruby'
  include SendGrid

  def notify_inspector(notification)
    @notification = notification
    @inspection_url = address_inspection_url(@notification.inspection.address, @notification.inspection)
    @address_url = address_url(@notification.inspection.address)
    from = SendGrid::Email.new(email: 'rchelton@riverdaleparkmd.gov', name: 'CodeSoft')
    to = Email.new(email: notification.user.email)
    cc = Email.new(email: 'rchelton@riverdaleparkmd.gov') # Add your email here
    subject = @notification.title
    content = Content.new(
      type: 'text/html', 
      value: "You have been assigned a new inspection at <a href='#{@address_url}'>#{@notification.inspection.address.combadd}</a>. <br><br><strong>Description:</strong> #{@notification.inspection.description}. <br><br>You can view it here: <a href='#{@inspection_url}'>Inspection Link</a>"
    )
    
    mail = Mail.new
    mail.from = from
    mail.subject = subject
    personalization = Personalization.new
    personalization.add_to(to)
    personalization.add_cc(cc) # Add CC here
    mail.add_personalization(personalization)
    mail.add_content(content)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end