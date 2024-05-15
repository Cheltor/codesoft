class StaticController < ApplicationController
  skip_before_action :authenticate_user!, only: [:issue, :dashboard, :helpful]

  def map
    if params[:show] == 'all'
      @addresses = Address.all
    elsif params[:show] == 'violations'
      # Add the addresses with violations to the address.units with violations
      @addresses = Address.left_joins(:violations, units: :violations)
      .where(violations: { status: :current })
      .or(Address.left_joins(:violations, units: :violations)
      .where(units: { violations: { status: :current } }))
    else
      @addresses = Address.joins(:violations).where(violations: { status: :current })
    end
  
    if params[:qmap].present?
      @search = Address.ransack(combadd_or_property_name_or_ownername_cont: params[:qmap])
      @addresses = @search.result
    end
  end

  def dashboard
    @user = current_user
    @comments = @user.comments.order(created_at: :desc)

    # fetch all comments
    violation_comments = @user.violations.flat_map(&:violation_comments)
    citation_comments = @user.violations.flat_map { |violation| violation.citations.flat_map(&:citation_comments) }
    address_comments = @user.comments
    inspeciton_comments = @user.inspections.flat_map(&:inspection_comments)
    
    # Combine all comments
    dash_comments = (violation_comments + citation_comments + address_comments + inspeciton_comments).sort_by(&:created_at).reverse

    @comments_last_week = dash_comments.select { |comment| comment.created_at > 1.week.ago }.sort_by(&:created_at).reverse
    @comments_two_weeks_ago = @user.comments.where(created_at: 2.weeks.ago..1.week.ago).order(created_at: :desc)
    @active_violations = @user.violations.where(violations: { status: :current })
    @violations = @user.violations.where(violations: { status: :current })
                                 .select {|violation| violation.deadline_date <= Date.tomorrow }
                                 .reject {|violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).any? {|citation| citation.deadline >= Date.tomorrow }}
                                 .sort_by(&:deadline_date)
  
    @citations = @user.citations.where(citations: { status: [:unpaid, "pending trial"] }).sort_by(&:deadline)
    @addresses = @q.result.where.not(streetnumb: nil)
    @inspections = Inspection.where(inspector: @user, status: nil).order(created_at: :desc)
    @today_inspections = Inspection.where(inspector: @user, status: nil, scheduled_datetime: Date.today.beginning_of_day..Date.today.end_of_day).order(scheduled_datetime: :desc)
    @future_inspections = Inspection
    .where(inspector: @user, status: nil)
    .where('scheduled_datetime > ?', Date.today.end_of_day)
    .order(scheduled_datetime: :desc)
    @past_inspections = Inspection.where(inspector: @user, status: nil).where('scheduled_datetime < ?', Date.today.beginning_of_day).order(scheduled_datetime: :desc)
    @complaints = Inspection.where(inspector: @user, status: nil, source: "Complaint").order(created_at: :desc)
    @unscheduled_inspections = Inspection.where(inspector: @user, status: nil, scheduled_datetime: nil).where.not(source: "Complaint").order(created_at: :desc)
    @priority_addresses = []
  
    # Print information about addresses being added to priority_addresses
    @violations.each do |violation|
      address = violation.address
      puts "Adding violation address #{address.id} to priority_addresses"
      @priority_addresses << address
    end
  
    @citations.each do |citation|
      address = citation.violation.address
      puts "Adding citation address #{address.id} to priority_addresses"
      @priority_addresses << address
    end
  
    @inspections.each do |inspection|
      address = inspection.address
      puts "Adding inspection address #{address.id} to priority_addresses"
      @priority_addresses << address
    end
  
    @priority_addresses = @priority_addresses.uniq.select { |address| !address.updated_at.today? }.sort_by(&:streetnumb)
    
    # Timeline
    user = current_user  # Assuming you have a method to fetch the current user

    # This used to fetch user related records, but now collects all
    user_violations = Violation.all
    user_comments = Comment.all  
    user_inspections = Inspection.all
    user_citations = Citation.all
    user_violation_comments = ViolationComment.all
    user_citation_comments = CitationComment.all
    user_inspection_comments = InspectionComment.all
    # ... fetch other records as needed ...

    # Combine and sort records for the timeline
    @timeline_items = (
      user_violations.to_a + 
      user_comments.to_a + 
      user_inspections.to_a +
      user_citations.to_a +
      user_violation_comments.to_a +
      user_citation_comments.to_a +
      user_inspection_comments.to_a
      # ... include other records here ...
    ).sort_by(&:created_at).reverse

    # Pagination (optional)
    page = params[:page] || 1
    per_page = 10  # Adjust as needed
    @timeline_items = WillPaginate::Collection.create(page, per_page, @timeline_items.size) do |pager|
      start_index = pager.offset
      pager.replace(@timeline_items[start_index, per_page])
    end
  end
  

  def issue
    @addresses = @q.result.where.not(streetnumb: nil)
    @concern = Concern.new # Create a new concern object for the form
  end

  def helpful
  end

  def admin
    @addresses = @q.result.where.not(streetnumb: nil)

    @ons_users = User.where(role: :ons)


    if params[:onsstaff].present?
      @user = User.find_by(email: params[:onsstaff])
      @notifications = @user.notifications.order(created_at: :desc)
      @comments = @user.comments.order(created_at: :desc)
      @comments_last_week = @user.comments.where(created_at: 1.week.ago..Time.now).order(created_at: :desc)
      @comments_two_weeks_ago = @user.comments.where(created_at: 2.weeks.ago..1.week.ago).order(created_at: :desc)
      @active_violations = @user.violations.where(violations: { status: :current })
      @violations = @user.violations.where(violations: { status: :current })
                                   .select {|violation| violation.deadline_date <= Date.tomorrow }
                                   .reject {|violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).any? {|citation| citation.deadline >= Date.tomorrow }}
                                   .sort_by(&:deadline_date)
    
      @citations = @user.citations.where(citations: { status: [:unpaid, "pending trial"] }).sort_by(&:deadline)
      @addresses = @q.result.where.not(streetnumb: nil)
      @inspections = Inspection.where(inspector: @user, status: nil).order(created_at: :desc)
      @today_inspections = Inspection.where(inspector: @user, status: nil, scheduled_datetime: Date.today.beginning_of_day..Date.today.end_of_day).order(scheduled_datetime: :desc)
      @future_inspections = Inspection
      .where(inspector: @user, status: nil)
      .where('scheduled_datetime > ?', Date.today.end_of_day)
      .order(scheduled_datetime: :desc)
      @past_inspections = Inspection.where(inspector: @user, status: nil).where('scheduled_datetime < ?', Date.today.beginning_of_day).order(scheduled_datetime: :desc)
      @complaints = Inspection.where(inspector: @user, status: nil, source: "Complaint").order(created_at: :desc)
      @unscheduled_inspections = Inspection.where(inspector: @user, status: nil, scheduled_datetime: nil).where.not(source: "Complaint").order(created_at: :desc)
      @priority_addresses = []
    
      # Print information about addresses being added to priority_addresses
      @violations.each do |violation|
        address = violation.address
        puts "Adding violation address #{address.id} to priority_addresses"
        @priority_addresses << address
      end
    
      @citations.each do |citation|
        address = citation.violation.address
        puts "Adding citation address #{address.id} to priority_addresses"
        @priority_addresses << address
      end
    
      @inspections.each do |inspection|
        address = inspection.address
        puts "Adding inspection address #{address.id} to priority_addresses"
        @priority_addresses << address
      end
    
      @priority_addresses = @priority_addresses.uniq.select { |address| !address.updated_at.today? }.sort_by(&:streetnumb)

      # Timeline
      user = @user  # Assuming you have a method to fetch the current user

      # Fetch user-related records
      user_violations = user.violations
      user_comments = user.comments  # Adjust based on your associations
      user_inspections = user.inspections
      user_citations = user.citations
      user_violation_comments = user.violation_comments
      user_citation_comments = user.citation_comments
      user_inspection_comments = user.inspection_comments
      # ... fetch other records as needed ...

      # Combine and sort records for the timeline
      @timeline_items = (
        user_violations.to_a +
        user_comments.to_a +
        user_citations.to_a +
        user_inspections.to_a +
        user_violation_comments.to_a +
        user_citation_comments.to_a +
        user_inspection_comments.to_a
        # ... include other records here ...
      ).sort_by(&:created_at).reverse

      # Pagination (optional)
      page = params[:page] || 1
      per_page = 10  # Adjust as needed
      @timeline_items = WillPaginate::Collection.create(page, per_page, @timeline_items.size) do |pager|
        start_index = pager.offset
        pager.replace(@timeline_items[start_index, per_page])
      end
    else
      @comments = Comment.order(created_at: :desc)
      @comments_last_week = Comment.where(created_at: 1.week.ago..Time.now).order(created_at: :desc)
      @comments_two_weeks_ago = Comment.where(created_at: 2.weeks.ago..1.week.ago).order(created_at: :desc)
      @active_violations = Violation.where(violations: { status: :current })
      @violations = Violation.where(violations: { status: :current })
                                   .select {|violation| violation.deadline_date <= Date.tomorrow }
                                   .reject {|violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).any? {|citation| citation.deadline >= Date.tomorrow }}
                                   .sort_by(&:deadline_date)
    
      @citations = Citation.where(citations: { status: [:unpaid, "pending trial"] }).sort_by(&:deadline)
      @addresses = @q.result.where.not(streetnumb: nil)
      @inspections = Inspection.where(status: nil).order(created_at: :desc)
      @today_inspections = Inspection.where(status: nil, scheduled_datetime: Date.today.beginning_of_day..Date.today.end_of_day).order(scheduled_datetime: :asc)
      @future_inspections = Inspection
      .where(status: nil)
      .where('scheduled_datetime > ?', Date.today.end_of_day)
      .order(scheduled_datetime: :desc)
      @past_inspections = Inspection.where(status: nil).where('scheduled_datetime < ?', Date.today.beginning_of_day).order(scheduled_datetime: :desc)
      @complaints = Inspection.where(status: nil, source: "Complaint").order(created_at: :desc)
      @unscheduled_inspections = Inspection.where(status: nil, scheduled_datetime: nil).where.not(source: "Complaint").order(created_at: :desc)
      @priority_addresses = []
    
      # Print information about addresses being added to priority_addresses
      @violations.each do |violation|
        address = violation.address
        puts "Adding violation address #{address.id} to priority_addresses"
        @priority_addresses << address
      end
    
      @citations.each do |citation|
        address = citation.violation.address
        puts "Adding citation address #{address.id} to priority_addresses"
        @priority_addresses << address
      end
    
      @inspections.each do |inspection|
        address = inspection.address
        puts "Adding inspection address #{address.id} to priority_addresses"
        @priority_addresses << address
      end
    
      @priority_addresses = @priority_addresses.uniq.select { |address| !address.updated_at.today? }.sort_by(&:streetnumb)  

      # Timeline for all users
      # Fetch user-related records
      user_violations = Violation.all
      user_comments = Comment.all  # Adjust based on your associations
      user_citations = Citation.all
      user_inspections = Inspection.all
      user_violation_comments = ViolationComment.all
      user_citation_comments = CitationComment.all
      user_inspection_comments = InspectionComment.all
      # ... fetch other records as needed ...

      # Combine and sort records for the timeline
      @timeline_items = (
        user_violations.to_a +
        user_comments.to_a +
        user_citations.to_a +
        user_inspections.to_a +
        user_violation_comments.to_a +
        user_citation_comments.to_a +
        user_inspection_comments.to_a
        # ... include other records here ...
      ).sort_by(&:created_at).reverse

      # Pagination (optional)
      page = params[:page] || 1
      per_page = 10  # Adjust as needed
      @timeline_items = WillPaginate::Collection.create(page, per_page, @timeline_items.size) do |pager|
        start_index = pager.offset
        pager.replace(@timeline_items[start_index, per_page])
      end

    end
  end

  def mark_reviewed
    @address = Address.find(params[:id])

    @address.update(outstanding: !@address.outstanding)

    redirect_to root_path
  end

  def design_test
  end


  def admin_user
    unless current_user.admin?
      redirect_to root_path, notice: "You are not authorized to access this page."
    end

    @users = User.all
  end
  
  def admin_edit_user
    @user = User.find(params[:id])

    if request.patch? # Check if it's a PATCH request (e.g., form submission)
      if @user.update(user_params)
        # Handle successful update, e.g., redirect to user list or show page
        redirect_to admin_user_path, notice: 'User role updated successfully.'
      else
        # Handle validation errors, if any
        render :admin_edit_user
      end
    end
  end

  def update_user
    unless current_user.admin?
      redirect_to root_path, notice: "You are not authorized to access this page."
    end
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path, notice: "User updated successfully."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :role, :phone)
  end
end
