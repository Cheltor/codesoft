module ApplicationHelper
  def format_phone_number(phone)
    phone_number_pattern = /^\(\d{3}\) \d{3}-\d{4}$/
    
    if phone.match?(phone_number_pattern)
      # Phone number is already properly formatted, return as-is
      phone
    else
      # Reformat the phone number to (XXX) XXX-XXXX format
      formatted_phone = "(#{phone[0..2]}) #{phone[3..5]}-#{phone[6..9]}"
      formatted_phone
    end
  end
end
