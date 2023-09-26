module InspectionsHelper
  def assignee_options(selected_assignee)
    users = User.ons.order(:email)
    options = [["Unassigned", nil]] # Adding "Unassigned" option as the first element
    options += users.pluck(:email, :id)
    options_for_select(options, selected_assignee)
  end

  def generate_pre_inspection_email_link
    recipient_email = @inspection.contact.email
    subject = "Pre-Inspection Notification for #{@inspection.source}"
    body = "
    You are receiving this email to inform you #{@inspection.address.combadd} has been scheduled for its annual inspection on 09/25/2023 between the hours of 12:00pm - 01:00pm. I look forward to our collaboration and thank you for your role in ensuring life and safety in Riverdale Park. Should you have questions or concerns please reply to this email. Lastly, please confirm your receipt of this email."

    mail_to(recipient_email, subject, body: body, class: "btn btn-primary")
  end

  def generate_inspection_email_link
    recipient_email = @inspection.contact.email
    subject = "Inspection Result"
    body = "Hello, this is an inspection result."

    mail_to(recipient_email, subject, body: body, class: "btn btn-primary")
  end
end