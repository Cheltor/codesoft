module InspectionsHelper
  def assignee_options(selected_assignee)
    users = User.ons.order(:email)
    options = [["Unassigned", nil]] # Adding "Unassigned" option as the first element
    options += users.pluck(:email, :id)
    options_for_select(options, selected_assignee)
  end

  def generate_pre_inspection_email_link
    if @inspection.scheduled_datetime.present?
      recipient_email = @inspection.contact.email
      subject = "Pre-Inspection Notification for #{@inspection.source}"
      body = "
      You are receiving this email to inform you #{@inspection.address.combadd} has been scheduled for its annual inspection on #{@inspection.scheduled_datetime.strftime('%m/%d/%Y')} between the hours of #{@inspection.scheduled_datetime.strftime('%I:%M%p')} - #{(@inspection.scheduled_datetime + 1.hour).strftime('%I:%M%p')}.      I look forward to our collaboration and thank you for your role in ensuring life and safety in Riverdale Park.
      
      Should you have questions or concerns please reply to this email. Lastly, please confirm your receipt of this email."
    
      mail_to(recipient_email, subject, body: body, class: "btn btn-secondary") do
        # Customize the button text here
        "Pre inspection email"
      end
    else
      receipient_email = @inspection.contact.email
      subject = "Pre-Inspection Notification for #{@inspection.source}"
      body = "Hello, this is a pre-inspection notification."

      mail_to(recipient_email, subject, body: body, class: "btn btn-secondary") do
        # Customize the button text here
        "Pre inspection email"
      end
    end
  end

  def generate_inspection_email_link
    recipient_email = @inspection.contact.email
    subject = "Inspection Result"
    body = "Hello, this is an inspection result."

    mail_to(recipient_email, subject, body: body, class: "btn btn-primary")
  end
end