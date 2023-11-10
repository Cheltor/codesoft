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
      subject = "Pre-Inspection Notification for #{@inspection.source.titleize}"
      body = "Hello, 
      
      This is a pre-inspection notification.

      You are receiving this email to inform you #{@inspection.address.combadd} has been scheduled for its annual inspection on #{@inspection.scheduled_datetime.strftime('%m/%d/%Y')} between the hours of #{@inspection.scheduled_datetime.strftime('%I:%M%p')} - #{(@inspection.scheduled_datetime + 1.hour).strftime('%I:%M%p')}.      I look forward to our collaboration and thank you for your role in ensuring life and safety in Riverdale Park.
      
      During the inspection, the property will be evaluated for compliance with Town codes and ordinances. For more information on the Town’s codes and ordinances, please visit the Town’s website at www.riverdaleparkmd.gov.

      Should you have questions or concerns please reply to this email. Lastly, please confirm your receipt of this email.
      
      Best Regards,
      
      #{current_user.name}
      #{current_user.phone}
      #{current_user.email}"
    
      mail_to(recipient_email, subject: subject, body: body, class: "btn btn-secondary") do
        # Customize the button text here
        "Pre inspection email"
      end
    else
      receipient_email = @inspection.contact.email
      subject = "Pre-Inspection Notification for #{@inspection.source.titleize}"
      body = "Hello, 
      This is a pre-inspection notification.
      
      You are receiving this email to inform you that #{@inspection.address.combadd} is pending an inspection for #{@inspection.source.titleize}. The inspection date and time have not yet been scheduled. We will notify you as soon as the inspection is scheduled.
      
      I look forward to our collaboration and thank you for your role in ensuring life and safety in Riverdale Park.
      
      During the inspection, the property will be evaluated for compliance with Town codes and ordinances. For more information on the Town’s codes and ordinances, please visit the Town’s website at www.riverdaleparkmd.gov.
      
      Should you have questions or concerns, please reply to this email. Lastly, please confirm your receipt of this email.
      
      Best Regards,
      
      #{current_user.name}
      #{current_user.phone}
      #{current_user.email}"
      

      mail_to(recipient_email, subject: subject, body: body, class: "btn btn-secondary") do
        # Customize the button text here
        "Pre inspection email"
      end
    end
  end

  def generate_inspection_email_link
    inspection = @inspection
    recipient_email = @inspection.contact.email
    subject = "Inspection Result for #{inspection.source.titleize}"
    body = "
    Hello,

    We are writing to inform you that the annual inspection for #{inspection.address.combadd} has been completed#{'. The inspection was conducted on ' if inspection.scheduled_datetime.present?}#{inspection.scheduled_datetime.strftime('%m/%d/%Y') if inspection.scheduled_datetime.present?}.

    Inspection Status: #{inspection.status}
    #{'Congratulations, your property has passed the inspection. We appreciate your cooperation and thank you for your role in ensuring life and safety in Riverdale Park.' if inspection.status == 'Satisfactory'}
    #{'Unfortunately, your property did not pass the inspection. Please see the attached report for details on the areas that require attention. For a detailed report, please refer to the attached inspection document. For more information on the Town’s codes and ordinances, please visit the Town’s website at www.riverdaleparkmd.gov.' if inspection.status == 'Unsatisfactory'}
    #{'' if inspection.status == 'Unsatisfactory'}

    #{'Inspection Codes: ' + inspection.code_ids.join(', ') if inspection.code_ids.present?}


    Should you have questions or concerns, please reply to this email.

    Best Regards,

    #{current_user.name}
    #{current_user.phone}
    #{current_user.email}
    "
    mail_to(recipient_email, subject: subject, body: body, class: "btn btn-primary") do
      # Customize the button text here
      "Inspection result email"
    end
  end

  def business_options(businesses)
    options = []
    options << ["No Business", nil]
    options += businesses.pluck(:name, :id)
    options_for_select(options)
  end
end