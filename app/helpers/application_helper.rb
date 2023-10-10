module ApplicationHelper
  def format_phone_number(phone)
    # Remove all non-numeric characters from the phone number
    numeric_phone = phone.gsub(/\D/, '')

    if numeric_phone.length == 10
      # Format as (XXX) XXX-XXXX for a 10-digit number
      formatted_phone = "(#{numeric_phone[0..2]}) #{numeric_phone[3..5]}-#{numeric_phone[6..9]}"
      formatted_phone
    else
      # Handle other cases or return the original input if it doesn't match expectations
      phone
    end
  end
end
