module InspectionsHelper
  def assignee_options(selected_assignee)
    users = User.ons.order(:email)
    options = [["Unassigned", nil]] # Adding "Unassigned" option as the first element
    options += users.pluck(:email, :id)
    options_for_select(options, selected_assignee)
  end
end