class StaticController < ApplicationController
  skip_before_action :authenticate_user!, only: [:issue, :dashboard, :helpful]

  def dashboard
    @user = current_user
    @comments = @user.comments.order(created_at: :desc)
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
  
    @priority_addresses = @priority_addresses.uniq.sort_by(&:streetnumb)
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
      @violations = @user.violations.where(violations: { status: :current })
                          .select {|violation| violation.deadline_date <= Date.tomorrow }
                          .reject {|violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).any? {|citation| citation.deadline >= Date.tomorrow }}
                          .sort_by(&:deadline_date)
      @citations = @user.citations.where(citations: { status: [:unpaid, "pending trial"] }).sort_by(&:deadline)
      @comments = @user.comments.order(created_at: :desc).limit(50)
      @inspections = Inspection.where(inspector: @user).order(created_at: :desc).limit(50)
    else
      @violations = Violation.where(violations: { status: :current })
                              .select {|violation| violation.deadline_date <= Date.tomorrow }
                              .reject {|violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).any? {|citation| citation.deadline >= Date.tomorrow }}
                              .sort_by(&:deadline_date)
      @citations = Citation.where(citations: { status: [:unpaid, "pending trial"] }).sort_by(&:deadline)
      @comments = Comment.order(created_at: :desc).limit(50)
      @inspections = Inspection.order(scheduled_datetime: :asc).limit(50)
    end
  end

  def admin_user
    unless current_user.admin?
      redirect_to root_path, notice: "You are not authorized to access this page."
    end

    @users = User.all
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
