module InspectionsHelper
  def assignee_options(selected_assignee)
    users = User.ons.order(:email)
    options = [["Unassigned", nil]] # Adding "Unassigned" option as the first element
    options += users.pluck(:email, :id)
    options_for_select(options, selected_assignee)
  end

  def generate_pre_inspection_email_link
    recipient_email = "recipient@example.com"
    subject = "Pre-Inspection Notification"
    body = "Hello, this is a pre-inspection notification."

    mail_to(recipient_email, subject, body: body, class: "btn btn-primary")
  end

  def generate_inspection_email_link
    recipient_email = ""
    subject = "Inspection Result"
    body = "Hello, this is an inspection result."

    mail_to(recipient_email, subject, body: body, class: "btn btn-primary")
  end
end